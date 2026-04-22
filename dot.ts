#!/usr/bin/env bun

import { readdir, stat, readFile } from "fs/promises";
import { join, basename } from "path";
import { existsSync } from "fs";
import { execSync, spawn } from "child_process";

const PACKAGES_DIR = join(import.meta.dir, "packages");
const HOME_DIR = process.env.HOME || "/home/shad";

interface PackageInfo {
  name: string;
  description: string;
  requiredPackages: string[];
  files: { source: string; target: string }[];
  configure?: string;
  enableScripts: { name: string; init?: string; description: string }[];
  cleanSteps: string[];
}

async function getPackageInfo(name: string): Promise<PackageInfo | null> {
  const pkgDir = join(PACKAGES_DIR, name);
  const readmePath = join(pkgDir, "README.md");

  if (!existsSync(pkgDir)) {
    console.error(`Package "${name}" not found`);
    return null;
  }

  const readme = existsSync(readmePath) ? await readFile(readmePath, "utf-8") : "";

  const info: PackageInfo = {
    name,
    description: extractDescription(readme),
    requiredPackages: extractRequiredPackages(readme),
    files: await collectFiles(pkgDir),
    configure: existsSync(join(pkgDir, "configure.sh")) ? "configure.sh" : undefined,
    enableScripts: collectEnableScripts(pkgDir),
    cleanSteps: extractCleanSteps(readme),
  };

  return info;
}

function extractDescription(readme: string): string {
  const match = readme.match(/^# \w+ - (.+)/m);
  return match ? match[1] : "No description";
}

function extractRequiredPackages(readme: string): string[] {
  const matches = readme.matchAll(/xbps-install (\S+)|apt install (\S+)|pacman -S (\S+)/g);
  const pkgs = new Set<string>();
  for (const m of matches) {
    pkgs.add(m[1] || m[2] || m[3]);
  }
  return Array.from(pkgs);
}

async function collectFiles(pkgDir: string): Promise<{ source: string; target: string }[]> {
  const files: { source: string; target: string }[] = [];

  async function walk(dir: string, baseDir: string) {
    const entries = await readdir(dir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = join(dir, entry.name);
      const relativePath = fullPath.replace(baseDir + "/", "");

      if (entry.name === "configure.sh" || entry.name.startsWith("enable") || entry.name.startsWith("disable") || entry.name === "README.md") {
        continue;
      }

      if (entry.isDirectory()) {
        await walk(fullPath, baseDir);
      } else {
        const target = resolveTarget(relativePath, pkgDir);
        files.push({ source: relativePath, target });
      }
    }
  }

  await walk(pkgDir, pkgDir);
  return files;
}

function resolveTarget(relativePath: string, pkgDir: string): string {
  if (relativePath.startsWith("home/")) {
    const stripped = relativePath.replace("home/", "");
    return join(HOME_DIR, stripped);
  } else if (relativePath.startsWith("system/")) {
    return "/" + relativePath.replace("system/", "");
  } else if (relativePath.startsWith("systemd/")) {
    return "/" + relativePath.replace("systemd/", "");
  }
  return "/" + relativePath;
}

function collectEnableScripts(pkgDir: string): { name: string; init?: string; description: string }[] {
  const scripts: { name: string; init?: string; description: string }[] = [];
  const files = ["enable-runit.sh", "enable-systemd.sh", "enable.sh"];

  for (const file of files) {
    const path = join(pkgDir, file);
    if (existsSync(path)) {
      const init = file.includes("runit") ? "runit" : file.includes("systemd") ? "systemd" : undefined;
      const name = file.replace(".sh", "");
      const desc = `Enables the service (${init || "generic"})`;
      scripts.push({ name, init, description: desc });
    }
  }

  return scripts;
}

function extractCleanSteps(readme: string): string[] {
  const match = readme.match(/## Clean[\s\S]*$/m);
  if (!match) return [];
  return match[0].split("\n").filter(l => l.startsWith("- ")).map(l => l.substring(2));
}

function printInfo(info: PackageInfo) {
  console.log(`\x1b[1m${info.name}\x1b[0m - ${info.description}\n`);

  console.log("\x1b[36mOperations:\x1b[0m");
  if (info.files.some(f => f.target.startsWith(HOME_DIR))) {
    console.log(`  dot link-home ${info.name}`);
  }
  if (info.files.some(f => !f.target.startsWith(HOME_DIR))) {
    console.log(`  dot link-system ${info.name}`);
  }
  if (info.configure) {
    console.log(`  dot configure ${info.name}`);
  }
  for (const s of info.enableScripts) {
    const initHint = s.init ? ` --init ${s.init}` : "";
    console.log(`  dot enable ${info.name}${initHint}`);
  }
  if (info.cleanSteps.length > 0) {
    console.log(`  dot clean ${info.name}`);
  }
  console.log("");

  if (info.requiredPackages.length > 0) {
    console.log("\x1b[33mRequired packages:\x1b[0m");
    for (const pkg of info.requiredPackages) {
      console.log(`  ${pkg}`);
    }
    console.log("");
  }

  if (info.files.length > 0) {
    console.log("\x1b[36mFiles:\x1b[0m");
    for (const f of info.files) {
      console.log(`  ${f.source} → ${f.target}`);
    }
    console.log("");
  }
}

function printClean(info: PackageInfo) {
  console.log(`\n\x1b[1mClean ${info.name}\x1b[0m\n`);

  if (info.files.length > 0) {
    console.log("\x1b[31mUnlink files:\x1b[0m");
    const homeFiles = info.files.filter(f => f.target.startsWith(HOME_DIR));
    const systemFiles = info.files.filter(f => !f.target.startsWith(HOME_DIR));
    if (homeFiles.length > 0) {
      console.log(`  dot unlink-home ${info.name}`);
    }
    if (systemFiles.length > 0) {
      console.log(`  dot unlink-system ${info.name}`);
    }
    console.log("");
  }

  if (info.enableScripts.length > 0) {
    console.log("\x1b[31mDisable service:\x1b[0m");
    for (const s of info.enableScripts) {
      const initHint = s.init ? ` --init ${s.init}` : "";
      console.log(`  dot disable ${info.name}${initHint}`);
    }
    console.log("");
  }
}

async function linkFiles(section: "home" | "system", packageName: string): Promise<number> {
  const pkgDir = join(PACKAGES_DIR, packageName);
  const dirPrefix = section === "home" ? "home" : "system";
  const sourceDir = join(pkgDir, dirPrefix);

  if (!existsSync(sourceDir)) {
    console.log(`No ${section} files to link for ${packageName}`);
    return 0;
  }

  const needSudo = section === "system";

  if (needSudo) {
    const { execSync } = await import("child_process");
    try {
      execSync("sudo -v", { stdio: "ignore" });
    } catch {
      console.error("sudo password required");
      return 0;
    }
  }

  console.log(`Linking ${section} files for ${packageName}...`);

  const { execSync } = await import("child_process");
  const sudoPrefix = needSudo ? "sudo " : "";
  let count = 0;

  async function walk(dir: string, baseDir: string) {
    const entries = await readdir(dir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = join(dir, entry.name);
      const relativePath = fullPath.replace(pkgDir + "/", "");

      if (entry.name === "README.md" || entry.name.startsWith("enable") || entry.name === "configure.sh") {
        continue;
      }

      if (entry.isDirectory()) {
        await walk(fullPath, baseDir);
      } else {
        const isHome = relativePath.startsWith("home/");
        const targetRel = isHome
          ? relativePath.replace("home/", "")
          : relativePath.replace("system/", "");
        const target = isHome
          ? join(HOME_DIR, targetRel)
          : "/" + targetRel;

        const targetDir = target.substring(0, target.lastIndexOf("/"));

        try {
          execSync(`${sudoPrefix}mkdir -p "${targetDir}"`);
          execSync(`${sudoPrefix}rm -rf "${target}"`);
          execSync(`${sudoPrefix}ln -sf "${fullPath}" "${target}"`);
          console.log(`  ${relativePath} → ${target}`);
          count++;
        } catch (e: unknown) {
          const err = e instanceof Error ? e.message : String(e);
          console.error(`  Failed to link ${relativePath}: ${err}`);
        }
      }
    }
  }

  await walk(sourceDir, sourceDir);
  console.log(`\nLinked ${count} ${section} files`);
  return count;
}

async function unlinkFiles(section: "home" | "system", packageName: string): Promise<number> {
  const pkgDir = join(PACKAGES_DIR, packageName);
  const dirPrefix = section === "home" ? "home" : "system";
  const sourceDir = join(pkgDir, dirPrefix);

  if (!existsSync(sourceDir)) {
    console.log(`No ${section} files to unlink for ${packageName}`);
    return 0;
  }

  const needSudo = section === "system";

  if (needSudo) {
    const { execSync } = await import("child_process");
    try {
      execSync("sudo -v", { stdio: "ignore" });
    } catch {
      console.error("sudo password required");
      return 0;
    }
  }

  console.log(`Unlinking ${section} files for ${packageName}...`);

  const { execSync } = await import("child_process");
  const sudoPrefix = needSudo ? "sudo " : "";
  let count = 0;

  async function walk(dir: string, baseDir: string) {
    const entries = await readdir(dir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = join(dir, entry.name);
      const relativePath = fullPath.replace(pkgDir + "/", "");

      if (entry.name === "README.md" || entry.name.startsWith("enable") || entry.name === "configure.sh") {
        continue;
      }

      if (entry.isDirectory()) {
        await walk(fullPath, baseDir);
      } else {
        const isHome = relativePath.startsWith("home/");
        const targetRel = isHome
          ? relativePath.replace("home/", "")
          : relativePath.replace("system/", "");
        const target = isHome
          ? join(HOME_DIR, targetRel)
          : "/" + targetRel;

        try {
          if (existsSync(target)) {
            execSync(`${sudoPrefix}rm -rf "${target}"`);
            console.log(`  Removed: ${target}`);
            count++;
          }
        } catch (e: unknown) {
          const err = e instanceof Error ? e.message : String(e);
          console.error(`  Failed to unlink ${target}: ${err}`);
        }
      }
    }
  }

  await walk(sourceDir, sourceDir);
  console.log(`\nUnlinked ${count} ${section} files`);
  return count;
}

async function runScript(scriptPath: string, needSudo = false): Promise<number> {
  console.log(`Running ${scriptPath}...`);
  const { spawn, execSync } = await import("child_process");

  if (needSudo) {
    try {
      execSync("sudo -v", { stdio: "ignore" });
    } catch {
      console.error("sudo password required");
      return 1;
    }
    return new Promise((resolve) => {
      const sudo = spawn("sudo", ["bash", scriptPath], { stdio: "inherit" });
      sudo.on("close", (code) => resolve(code || 0));
    });
  }

  return new Promise((resolve) => {
    const proc = spawn("bash", [scriptPath], { stdio: "inherit" });
    proc.on("close", (code) => resolve(code || 0));
  });
}

const RED = "\033[0;31m";
const GREEN = "\033[0;32m";
const YELLOW = "\033[1;33m";
const BLUE = "\033[0;34m";
const BOLD = "\033[1m";
const NC = "\033[0m";

function logInfo(msg: string) { console.log(`${GREEN}[INFO]${NC} ${msg}`); }
function logWarn(msg: string) { console.log(`${YELLOW}[WARN]${NC} ${msg}`); }
function logError(msg: string) { console.error(`${RED}[ERROR]${NC} ${msg}`); }
function logSection(msg: string) { console.log(`\n${BOLD}${BLUE}=== ${msg} ===${NC}`); }

function commandExists(cmd: string): boolean {
  try {
    execSync(`command -v ${cmd} &>/dev/null`, { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

function getVersion(cmd: string, args: string[]): string {
  try {
    return execSync(`${cmd} ${args.join(" ")} 2>/dev/null`, { encoding: "utf-8" }).trim();
  } catch {
    return "unknown";
  }
}

async function updateXbps(checkOnly: boolean) {
  if (!commandExists("xbps-install")) {
    logWarn("XBPS not found, skipping");
    return;
  }
  if (checkOnly) {
    try {
      const out = execSync("xbps-install -Su 2>&1", { encoding: "utf-8", stdio: "pipe" });
      if (out.includes("Nothing to upgrade")) {
        logInfo("xbps: all packages up to date");
      } else {
        console.log(out);
      }
    } catch {
      logInfo("xbps: skipped (requires sudo)");
    }
    return;
  }
  logInfo("xbps: synchronizing...");
  try { execSync("sudo xbps-install -S", { stdio: "inherit" }); } catch { logWarn("xbps: sync failed"); }
  logInfo("xbps: upgrading...");
  try { execSync("sudo xbps-install -Su", { stdio: "inherit" }); } catch { logWarn("xbps: upgrade failed"); }
}

async function updateFlatpak(checkOnly: boolean) {
  if (!commandExists("flatpak")) {
    logWarn("flatpak: not installed");
    return;
  }
  if (checkOnly) {
    try {
      execSync("flatpak remote-diff --updates", { stdio: "pipe" });
    } catch {
      logInfo("flatpak: no updates");
    }
    return;
  }
  try {
    execSync("sudo flatpak update -y", { stdio: "inherit" });
  } catch {
    logWarn("flatpak: update failed");
  }
}

async function updateDeno(checkOnly: boolean) {
  if (!commandExists("deno")) {
    logWarn("deno: not found");
    return;
  }
  if (checkOnly) {
    logInfo(`deno: ${getVersion("deno", ["--version"])}`);
    return;
  }
  execSync("deno upgrade", { stdio: "inherit" });
}

async function updateRustup(checkOnly: boolean) {
  if (!commandExists("rustup")) {
    logWarn("rustup: not found");
    return;
  }
  if (checkOnly) {
    logInfo(`rustup: ${getVersion("rustup", ["--version"])}`);
    return;
  }
  execSync("rustup update", { stdio: "inherit" });
}

async function updateBunSelf(checkOnly: boolean) {
  if (!commandExists("bun")) {
    logWarn("bun: not found");
    return;
  }
  if (checkOnly) {
    logInfo(`bun: ${getVersion("bun", ["--version"])}`);
    return;
  }
  execSync("bun upgrade", { stdio: "inherit" });
}

async function updateNpm(checkOnly: boolean) {
  if (!commandExists("npm")) {
    logWarn("npm: not found");
    return;
  }
  if (checkOnly) {
    logInfo(`npm: ${getVersion("npm", ["--version"])}`);
    try {
      const outdated = execSync("npm outdated -g --depth=0 2>/dev/null | tail -n +2", { encoding: "utf-8", stdio: "pipe" }).trim();
      if (outdated) {
        console.log(outdated);
      } else {
        logInfo("npm: all packages up to date");
      }
    } catch {
      logInfo("npm: all packages up to date");
    }
    return;
  }
  execSync("npm update -g", { stdio: "inherit" });
}

async function updateBunGlobal(checkOnly: boolean) {
  if (!commandExists("bun")) {
    logWarn("bun: not found");
    return;
  }
  if (checkOnly) {
    try {
      const outdated = execSync("bun outdated -g 2>/dev/null | tail -n +2", { encoding: "utf-8", stdio: "pipe" }).trim();
      if (outdated) {
        console.log(outdated);
      } else {
        logInfo("bun -g: all packages up to date");
      }
    } catch {
      logInfo("bun -g: all packages up to date");
    }
    return;
  }
  execSync("bun update -g", { stdio: "inherit" });
}

async function updateYarn(checkOnly: boolean) {
  if (!commandExists("yarn")) {
    logWarn("yarn: not found");
    return;
  }
  const pkgs = execSync("yarn global list --depth=0 2>/dev/null | grep -c info || true", { encoding: "utf-8" }).trim();
  if (pkgs === "0") {
    logWarn("yarn: no global packages");
    return;
  }
  if (checkOnly) {
    try {
      const outdated = execSync("yarn global outdated 2>/dev/null | tail -n +2", { encoding: "utf-8", stdio: "pipe" }).trim();
      if (outdated) {
        console.log(outdated);
      } else {
        logInfo("yarn: all packages up to date");
      }
    } catch {
      logInfo("All packages up to date");
    }
    return;
  }
  execSync("yarn global upgrade", { stdio: "inherit" });
}

async function updatePnpm(checkOnly: boolean) {
  if (!commandExists("pnpm")) {
    logWarn("pnpm: not found");
    return;
  }
  const pkgs = execSync("pnpm list -g --depth=0 2>/dev/null | grep -c \"@\" || true", { encoding: "utf-8" }).trim();
  if (pkgs === "0") {
    logWarn("pnpm: no global packages");
    return;
  }
  if (checkOnly) {
    try {
      const outdated = execSync("pnpm outdated -g 2>/dev/null | tail -n +2", { encoding: "utf-8", stdio: "pipe" }).trim();
      if (outdated) {
        console.log(outdated);
      } else {
        logInfo("pnpm: all packages up to date");
      }
    } catch {
      logInfo("pnpm: all packages up to date");
    }
    return;
  }
  execSync("pnpm update -g", { stdio: "inherit" });
}

async function updatePipx(checkOnly: boolean) {
  if (!commandExists("pipx") && !commandExists("pip")) {
    logWarn("pip: not found");
    return;
  }
  if (checkOnly) {
    if (commandExists("pipx")) {
      try {
        const outdated = execSync("pipx list 2>/dev/null", { encoding: "utf-8", stdio: "pipe" }).trim();
        if (outdated.includes("Nothing")) {
          logInfo("pipx: all packages up to date");
        } else {
          console.log(outdated);
        }
      } catch {
        logInfo("pipx: all packages up to date");
      }
    } else {
      logInfo(`pip: ${getVersion("pip", ["--version"])}`);
    }
    return;
  }
  if (commandExists("pipx")) {
    execSync("pipx upgrade-all", { stdio: "inherit" });
  } else {
    execSync("pip install --upgrade pip", { stdio: "inherit" });
  }
}

async function updateCargo(checkOnly: boolean) {
  if (!commandExists("cargo")) {
    logWarn("cargo: not found");
    return;
  }
  if (!commandExists("cargo-install-update")) {
    logWarn("cargo-install-update: not found (install with: cargo install cargo-install-update)");
    return;
  }
  if (checkOnly) {
    try {
      const outdated = execSync("cargo install-update --dry-run 2>&1", { encoding: "utf-8", stdio: "pipe" }).trim();
      if (outdated) {
        console.log(outdated);
      } else {
        logInfo("cargo: all crates up to date");
      }
    } catch {
      logInfo("cargo: all crates up to date");
    }
    return;
  }
  execSync("cargo install-update -a", { stdio: "inherit" });
}

async function updateFnm(checkOnly: boolean) {
  if (!commandExists("fnm")) {
    logWarn("fnm: not found");
    return;
  }
  const version = getVersion("fnm", ["--version"]);
  if (checkOnly) {
    logInfo(`fnm: ${version} (use --force to reinstall)`);
    return;
  }
  logInfo(`fnm: ${version}`);
  if (commandExists("npm")) {
    logInfo("fnm: reinstalling via npm...");
    execSync("npm install -g fnm", { stdio: "inherit" });
  } else if (commandExists("bun")) {
    logInfo("fnm: reinstalling via bun...");
    execSync("bun install -g fnm", { stdio: "inherit" });
  } else {
    logWarn("fnm: npm/bun not found");
    return;
  }
  logInfo(`fnm: updated to ${getVersion("fnm", ["--version"])}`);
}

async function updateAnyzig(checkOnly: boolean) {
  const installDir = join(HOME_DIR, ".local/bin");
  const zigPath = join(installDir, "zig");
  const url = "https://github.com/marler8997/anyzig/releases/download/v2026_03_26/anyzig-x86_64-linux.tar.gz";

  if (!existsSync(zigPath) && !commandExists("zig") && !commandExists("anyzig")) {
    logWarn("anyzig: not found");
    return;
  }
  if (checkOnly) {
    if (existsSync(zigPath)) {
      logInfo(`anyzig: installed at ${zigPath}`);
    } else {
      logInfo("anyzig: not installed");
    }
    return;
  }
  const tmpfile = execSync("mktemp /tmp/anyzig.tar.gz.XXXXXX", { encoding: "utf-8" }).trim();
  logInfo("anyzig: downloading...");
  execSync(`curl -L "${url}" -o ${tmpfile}`, { stdio: "inherit" });
  execSync(`mkdir -p "${installDir}"`, { stdio: "inherit" });
  execSync(`tar -xzf "${tmpfile}" -C "${installDir}"`, { stdio: "inherit" });
  execSync(`chmod +x "${zigPath}"`, { stdio: "inherit" });
  execSync(`rm -f "${tmpfile}"`, { stdio: "inherit" });
  logInfo("anyzig: updated");
}

async function updateLy(checkOnly: boolean) {
  const lyDir = join(HOME_DIR, ".builds/ly");
  const lyRepo = "https://codeberg.org/fairyglade/ly.git";
  const zigCmd = existsSync(join(HOME_DIR, ".local/bin/zig")) ? join(HOME_DIR, ".local/bin/zig") : "zig";

  if (!commandExists("git")) {
    logWarn("ly: git not found");
    return;
  }
  if (checkOnly) {
    if (existsSync(lyDir)) {
      const rev = execSync(`git -C "${lyDir}" rev-parse HEAD`, { encoding: "utf-8" }).trim();
      logInfo(`ly: ${rev.substring(0, 8)}`);
    } else {
      logInfo("ly: not cloned");
    }
    return;
  }
  if (!existsSync(lyDir)) {
    logInfo("ly: cloning...");
    execSync(`git clone --recurse-submodules "${lyRepo}" "${lyDir}"`, { stdio: "inherit" });
  } else {
    logInfo("ly: updating submodules...");
    execSync(`git -C "${lyDir}" submodule update --init --recursive`, { stdio: "inherit" });
    logInfo("ly: pulling...");
    execSync(`git -C "${lyDir}" pull`, { stdio: "inherit" });
  }
  const installed = commandExists("ly") || existsSync("/usr/bin/ly") || existsSync("/usr/local/bin/ly");
  if (installed) {
    logInfo("ly: already installed");
    return;
  }
  logInfo("ly: building...");
  const buildResult = execSync(`${zigCmd} build --build-file "${lyDir}/build.zig"`, { stdio: "pipe", encoding: "utf-8" });
  if (buildResult.includes("Build succeeded")) {
    const privCmd = commandExists("doas") ? "doas" : "sudo";
    execSync(`${privCmd} env "PATH=${HOME_DIR}/.local/bin:$PATH" ${zigCmd} build installnoconf --build-file "${lyDir}/build.zig"`, { stdio: "inherit" });
    logInfo("ly installed successfully");
  } else {
    logError("Build failed, skipping install");
  }
}

async function updateZinit(checkOnly: boolean) {
  const zinitDir = join(HOME_DIR, ".local/share/zinit");
  if (!existsSync(zinitDir)) {
    logWarn("zinit: not found");
    return;
  }
  if (!commandExists("zsh")) {
    logWarn("zinit: zsh not found");
    return;
  }
  if (checkOnly) {
    logInfo(`zinit: ${zinitDir}`);
    return;
  }
  execSync(`zsh -c "source ${zinitDir}/zinit.git/zinit.zsh && zinit self-update"`, { stdio: "inherit" });
  execSync(`zsh -c "source ${zinitDir}/zinit.git/zinit.zsh && zinit update"`, { stdio: "inherit" });
}

async function showUpdateInfo() {
  console.log(`\n${BOLD}System Information${NC}`);
  if (commandExists("xbps")) {
    console.log(`xbps: ${execSync("xbps-query -l | wc -l", { encoding: "utf-8" }).trim()} packages`);
  }
  console.log("\nPackage managers:");
  commandExists("xbps") && console.log("  xbps");
  commandExists("flatpak") && console.log("  flatpak");
  commandExists("npm") && console.log(`  npm: ${getVersion("npm", ["--version"])}`);
  commandExists("bun") && console.log(`  bun: ${getVersion("bun", ["--version"])}`);
  commandExists("yarn") && console.log(`  yarn`);
  commandExists("pnpm") && console.log(`  pnpm`);
  commandExists("pipx") && console.log(`  pipx`);
  commandExists("cargo") && console.log(`  cargo`);

  console.log("\nRuntimes:");
  commandExists("node") && console.log(`  node: ${getVersion("node", ["--version"])}`);
  commandExists("fnm") && console.log(`  fnm: ${getVersion("fnm", ["--version"])}`);
  commandExists("python3") && console.log(`  python: ${getVersion("python3", ["--version"])}`);
  commandExists("rustc") && console.log(`  rust: ${getVersion("rustc", ["--version"])}`);
  commandExists("go") && console.log(`  go: ${getVersion("go", ["version"])}`);
  commandExists("deno") && console.log(`  deno: ${getVersion("deno", ["--version"])}`);
  existsSync(join(HOME_DIR, ".local/bin/zig")) && console.log(`  zig`);
  commandExists("rustup") && console.log(`  rustup: ${getVersion("rustup", ["--version"])}`);
}

function printUpdateUsage() {
  console.log(`\nUsage: dot update void [category] [options]

Categories:
  void            Default (same as 'system')
  void system     Update package managers themselves (xbps, flatpak, deno, rustup, bun upgrade)
  void global     Update global packages (npm, bun -g, yarn, pnpm, pipx, cargo)
  void source     Update git-based tools (fnm, anyzig, ly, zinit)
  void all        Update all categories

Options:
  --check         Show what would be updated without making changes
  --info          Show system information and installed versions

Examples:
  dot update void         Update system (default)
  dot update void global  Update global packages
  dot update void source  Update git-based tools
  dot update void all     Update everything
  dot update void --check Check available updates
  dot update void --info Show system info
`);
}

async function handleUpdateVoid(args: string[]) {
  const categories = ["system", "global", "source", "all"];
  const checkIdx = args.indexOf("--check");
  const infoIdx = args.indexOf("--info");
  const checkOnly = checkIdx !== -1;
  const infoOnly = infoIdx !== -1;

  if (infoOnly) {
    await showUpdateInfo();
    return;
  }

  let category = "system";
  for (const cat of categories) {
    const idx = args.indexOf(cat);
    if (idx !== -1 && args[idx - 1] !== "void") {
      category = cat;
      break;
    }
  }

  if (category === "system" || category === "all") {
    await updateXbps(checkOnly);
    await updateFlatpak(checkOnly);
    await updateDeno(checkOnly);
    await updateRustup(checkOnly);
    await updateBunSelf(checkOnly);
  }
  if (category === "global" || category === "all") {
    await updateNpm(checkOnly);
    await updateBunGlobal(checkOnly);
    await updateYarn(checkOnly);
    await updatePnpm(checkOnly);
    await updatePipx(checkOnly);
    await updateCargo(checkOnly);
  }
  if (category === "source" || category === "all") {
    await updateFnm(checkOnly);
    await updateAnyzig(checkOnly);
    await updateLy(checkOnly);
    await updateZinit(checkOnly);
  }
}

const commands: Record<string, string> = {
  info: "Show package information",
  clean: "Show how to remove a package",
  "link-home": "Link files to $HOME",
  "link-system": "Link files to / (system)",
  configure: "Run configure script",
  enable: "Run enable script",
  unlink: "Unlink files",
  update: "Update Void Linux system and packages",
};

const args = Bun.argv.slice(2);

function printUsage() {
  console.log(`\nUsage: dot <command> [package] [options]

Commands:
  info        Show package information and required software
  clean       Show how to remove/uninstall a package
  link-home   Link files to $HOME (user directory)
  link-system Link files to / (system directory, requires sudo)
  configure   Run package configuration script
  enable      Enable package service (may require --init)
  unlink-home   Remove linked home files
  unlink-system Remove linked system files
  update      Update Void Linux system and packages (see: dot update --help)

Examples:
  dot info ly
  dot clean ly
  dot link-home ly
  sudo dot link-system ly
  sudo dot configure ly
  sudo dot enable ly --init runit
  sudo dot unlink-system ly

Run 'dot info <package>' first to see what options are available.
`);
}

async function main() {
  if (args.length === 0) {
    printUsage();
    process.exit(1);
  }

  const command = args[0];

  if (command === "update") {
    const updateArgs = args.slice(1);
    if (updateArgs.length === 0 || updateArgs[0] === "--help" || updateArgs[0] === "-h") {
      printUpdateUsage();
      process.exit(0);
    }
    if (updateArgs[0] === "void") {
      await handleUpdateVoid(updateArgs.slice(1));
    } else {
      logError(`Unknown update target: ${updateArgs[0]}`);
      printUpdateUsage();
      process.exit(1);
    }
    return;
  }

  const packageName = args[1];
  const initFlag = args.indexOf("--init");
  const init = initFlag !== -1 ? args[initFlag + 1] : undefined;
  const sectionFlag = args.indexOf("--section");
  const section = sectionFlag !== -1 ? args[sectionFlag + 1] : undefined;

  if (!packageName) {
    console.error(`Error: Package name required`);
    printUsage();
    process.exit(1);
  }

  const info = await getPackageInfo(packageName);
  if (!info) {
    process.exit(1);
  }

  switch (command) {
    case "info":
      printInfo(info);
      break;

    case "clean":
      printClean(info);
      break;

    case "link-home":
      await linkFiles("home", packageName);
      break;

    case "link-system":
      if (!init) {
        console.error("Error: --init required for link-system");
        console.error("Usage: sudo dot link-system <package> --init <runit|systemd>");
        process.exit(1);
      }
      await linkFiles("system", packageName);
      if (init === "systemd") {
        await linkFiles("systemd", packageName);
      }
      break;

    case "configure": {
      const scriptPath = join(PACKAGES_DIR, packageName, "configure.sh");
      if (!existsSync(scriptPath)) {
        console.log(`No configure script for ${packageName}`);
        break;
      }
      await runScript(scriptPath, true);
      break;
    }

    case "enable": {
      const scripts = info.enableScripts;
      let scriptName: string;

      if (scripts.length === 0) {
        console.log(`No enable script for ${packageName}`);
        break;
      } else if (scripts.length === 1) {
        scriptName = scripts[0].name;
      } else {
        if (!init) {
          console.error(`\nError: Multiple enable scripts found. Please specify --init:`);
          for (const s of scripts) {
            console.error(`  dot enable ${packageName} --init ${s.init}`);
          }
          process.exit(1);
        }
        const found = scripts.find(s => s.init === init);
        if (!found) {
          console.error(`Error: Unknown init system "${init}". Available: ${scripts.map(s => s.init).join(", ")}`);
          process.exit(1);
        }
        scriptName = found.name;
      }

      const scriptPath = join(PACKAGES_DIR, packageName, `${scriptName}.sh`);
      if (!existsSync(scriptPath)) {
        console.error(`Error: Script not found: ${scriptPath}`);
        process.exit(1);
      }
      await runScript(scriptPath, true);
      break;
    }

    case "disable": {
      const scripts = info.enableScripts;
      let scriptName: string;

      if (scripts.length === 0) {
        console.log(`No disable script for ${packageName}`);
        break;
      } else if (scripts.length === 1) {
        scriptName = scripts[0].name;
      } else {
        if (!init) {
          console.error(`\nError: Multiple disable options found. Please specify --init:`);
          for (const s of scripts) {
            console.error(`  dot disable ${packageName} --init ${s.init}`);
          }
          process.exit(1);
        }
        const found = scripts.find(s => s.init === init);
        if (!found) {
          console.error(`Error: Unknown init system "${init}". Available: ${scripts.map(s => s.init).join(", ")}`);
          process.exit(1);
        }
        scriptName = found.name;
      }

      const scriptPath = join(PACKAGES_DIR, packageName, `${scriptName}.sh`);
      if (!existsSync(scriptPath)) {
        console.error(`Error: Script not found: ${scriptPath}`);
        process.exit(1);
      }

      const disableScriptPath = scriptPath.replace("enable-", "disable-");
      if (!existsSync(disableScriptPath)) {
        console.log(`No disable script for ${packageName} (init: ${init})`);
        break;
      }

      await runScript(disableScriptPath, true);
      break;
    }

    case "unlink-home":
      await unlinkFiles("home", packageName);
      break;

    case "unlink-system":
      await unlinkFiles("system", packageName);
      await unlinkFiles("systemd", packageName);
      break;

    default:
      console.error(`Unknown command: ${command}`);
      printUsage();
      process.exit(1);
  }
}

main();