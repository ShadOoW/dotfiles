import { defineCommand } from "citty";
import { existsSync } from "fs";
import { mkdir, readdir } from "fs/promises";
import { join } from "path";
import { HOME_DIR, PKGBUILDS_DIR, CACHE_DIR } from "../lib/config.ts";
import { commandExists, getVersion, logDesc, logError, logInfo, logSection, logSuccess, logWarn } from "../lib/console.ts";
import { detectDistro } from "../lib/pkg.ts";
import { analyzeWithAI, captureAndStream } from "../lib/ai.ts";
import { findAsset, getLatestRelease } from "../lib/github.ts";

// ─── types ────────────────────────────────────────────────────────────────────

type Updater = {
  name: string;
  group: "system" | "global" | "source";
  run: (check: boolean) => Promise<boolean>;
};

// ─── individual updaters ─────────────────────────────────────────────────────

async function updateXbps(check: boolean): Promise<boolean> {
  if (!commandExists("xbps-install")) return true;
  if (check) { logInfo(`xbps: ${getVersion("xbps-query", ["--version"])}`); return true; }
  logSection("xbps");
  const r = Bun.spawnSync(["sudo", "xbps-install", "-Syu"], { stdout: "inherit", stderr: "inherit" });
  return r.exitCode === 0;
}

async function updatePacman(check: boolean): Promise<boolean> {
  if (!commandExists("pacman")) return true;
  if (check) { logInfo(`pacman: ${getVersion("pacman", ["--version"])}`); return true; }
  const priv = commandExists("doas") ? "doas" : "sudo";
  logSection("pacman");
  Bun.spawnSync([priv, "pacman", "-Syu", "--noconfirm", "--noprogressbar"], { stdout: "inherit", stderr: "inherit" });
  return true;
}

async function updateYay(check: boolean): Promise<boolean> {
  if (!commandExists("yay")) return true;
  if (check) { logInfo(`yay: ${getVersion("yay", ["--version"])}`); return true; }
  logSection("yay");
  Bun.spawnSync(["yay", "-Sau", "--noconfirm", "--sudoloop", "--noprogressbar"], { stdout: "inherit", stderr: "inherit" });
  return true;
}

async function updateFlatpak(check: boolean): Promise<boolean> {
  if (!commandExists("flatpak")) return true;
  if (check) { logInfo(`flatpak: ${getVersion("flatpak", ["--version"])}`); return true; }
  logSection("flatpak");
  Bun.spawnSync(["flatpak", "update", "-y"], { stdout: "inherit", stderr: "inherit" });
  return true;
}

async function updateBunSelf(check: boolean): Promise<boolean> {
  if (!commandExists("bun")) return true;
  if (check) { logInfo(`bun: ${getVersion("bun", ["--version"])}`); return true; }
  logSection("bun");
  Bun.spawnSync(["bun", "upgrade"], { stdout: "inherit", stderr: "inherit" });
  return true;
}

async function updateDeno(check: boolean): Promise<boolean> {
  if (!commandExists("deno")) return true;
  if (check) { logInfo(`deno: ${getVersion("deno", ["--version"])}`); return true; }
  logSection("deno");
  Bun.spawnSync(["deno", "upgrade"], { stdout: "inherit", stderr: "inherit" });
  return true;
}

async function updateRustup(check: boolean): Promise<boolean> {
  if (!commandExists("rustup")) return true;
  if (check) { logInfo(`rustup: ${getVersion("rustup", ["--version"])}`); return true; }
  logSection("rustup");
  Bun.spawnSync(["rustup", "update"], { stdout: "inherit", stderr: "inherit" });
  return true;
}

async function updateNpm(check: boolean): Promise<boolean> {
  if (!commandExists("npm")) return true;
  if (check) { logInfo(`npm: ${getVersion("npm", ["--version"])}`); return true; }
  logSection("npm");
  Bun.spawnSync(["npm", "update", "-g"], { stdout: "inherit", stderr: "inherit" });
  return true;
}

async function updateBunGlobal(check: boolean): Promise<boolean> {
  if (!commandExists("bun")) return true;
  if (check) { logInfo(`bun -g: ${getVersion("bun", ["outdated", "-g"])}`); return true; }
  logSection("bun global");
  const lockfile = join(HOME_DIR, ".bun/install/global/bun.lock");
  if (existsSync(lockfile)) Bun.file(lockfile).delete();
  Bun.spawnSync(["bun", "update", "-g"], { stdout: "inherit", stderr: "inherit" });
  return true;
}

async function updateYarn(check: boolean): Promise<boolean> {
  if (!commandExists("yarn")) return true;
  if (check) { logInfo("yarn: checking global packages…"); return true; }
  logSection("yarn");
  const lockfile = join(HOME_DIR, ".config/yarn/global/yarn.lock");
  if (existsSync(lockfile)) Bun.file(lockfile).delete();
  Bun.spawnSync(["yarn", "global", "upgrade", "--latest"], { stdout: "inherit", stderr: "inherit" });
  return true;
}

async function updatePnpm(check: boolean): Promise<boolean> {
  if (!commandExists("pnpm")) return true;
  if (check) { logInfo(`pnpm: ${getVersion("pnpm", ["--version"])}`); return true; }
  logSection("pnpm");
  Bun.spawnSync(["pnpm", "update", "-g", "--latest"], { stdout: "inherit", stderr: "inherit" });
  return true;
}

async function updatePipx(check: boolean): Promise<boolean> {
  if (!commandExists("pipx")) return true;
  if (check) { logInfo("pipx: listing packages…"); Bun.spawnSync(["pipx", "list"], { stdout: "inherit" }); return true; }
  logSection("pipx");
  Bun.spawnSync(["pipx", "upgrade-all"], { stdout: "inherit", stderr: "inherit" });
  return true;
}

async function updateCargo(check: boolean): Promise<boolean> {
  if (!commandExists("cargo")) return true;
  if (!commandExists("cargo-install-update")) {
    logWarn("cargo-install-update not found — install with: cargo install cargo-install-update");
    return true;
  }
  if (check) { Bun.spawnSync(["cargo", "install-update", "--dry-run"], { stdout: "inherit" }); return true; }
  logSection("cargo");
  Bun.spawnSync(["cargo", "install-update", "-a"], { stdout: "inherit", stderr: "inherit" });
  return true;
}

async function updateFnm(check: boolean): Promise<boolean> {
  if (!commandExists("cargo")) { logWarn("fnm: cargo not found, skipping"); return true; }
  if (check) { logInfo(`fnm: ${getVersion("fnm", ["--version"])}`); return true; }
  const vBefore = getVersion("fnm", ["--version"]);
  logInfo("fnm: updating via cargo…");
  const r = Bun.spawnSync(["cargo", "install", "fnm"], { stdout: "pipe", stderr: "pipe" });
  if (r.exitCode !== 0) {
    process.stderr.write(r.stderr);
    logError("fnm: install failed");
    return false;
  }
  const vAfter = getVersion("fnm", ["--version"]);
  if (vBefore !== vAfter) {
    logSuccess(`fnm: ${vBefore} → ${vAfter}`);
  } else {
    logSuccess(`fnm: up to date (${vAfter})`);
  }
  return true;
}

async function updateAnyzig(check: boolean): Promise<boolean> {
  const zigPath = join(HOME_DIR, ".local/bin/zig");
  if (!existsSync(zigPath) && !commandExists("zig")) return true;

  const release = await getLatestRelease("marler8997/anyzig");
  if (!release) {
    logWarn("anyzig: could not fetch latest release");
    return false;
  }
  const latestVer = release.tag_name;

  const verFile = join(CACHE_DIR, "anyzig.version");
  const installedVer = existsSync(verFile) ? (await Bun.file(verFile).text()).trim() : null;

  if (check) {
    logInfo(`anyzig: ${installedVer ?? "not tracked"} → ${latestVer}`);
    return true;
  }

  if (installedVer === latestVer && existsSync(zigPath)) {
    logSuccess(`anyzig: up to date (${latestVer})`);
    return true;
  }

  const asset = findAsset(release, /anyzig-x86_64-linux\.tar\.gz$/i);
  if (!asset) {
    logError("anyzig: no matching asset in release");
    return false;
  }

  logInfo(`anyzig: downloading ${latestVer}…`);
  const tmpR = Bun.spawnSync(["mktemp", "/tmp/anyzig.tar.gz.XXXXXX"], { stdout: "pipe" });
  const tmpfile = new TextDecoder().decode(tmpR.stdout).trim();
  const dlR = Bun.spawnSync(["curl", "-fsSL", asset.browser_download_url, "-o", tmpfile], { stdout: "pipe", stderr: "pipe" });
  if (dlR.exitCode !== 0) {
    logError("anyzig: download failed");
    Bun.spawnSync(["rm", "-f", tmpfile]);
    return false;
  }
  Bun.spawnSync(["tar", "-xzf", tmpfile, "-C", join(HOME_DIR, ".local/bin")], { stdout: "pipe" });
  Bun.spawnSync(["chmod", "+x", zigPath]);
  Bun.spawnSync(["rm", "-f", tmpfile]);
  await mkdir(CACHE_DIR, { recursive: true });
  await Bun.write(verFile, latestVer);
  logSuccess(`anyzig: ${installedVer ? `${installedVer} → ${latestVer}` : `installed (${latestVer})`}`);
  return true;
}

async function updateLy(check: boolean): Promise<boolean> {
  const lyDir = join(HOME_DIR, ".builds/ly");
  const lyRepo = "https://codeberg.org/fairyglade/ly.git";
  const zigCmd = existsSync(join(HOME_DIR, ".local/bin/zig")) ? join(HOME_DIR, ".local/bin/zig") : "zig";

  if (!commandExists("git")) return true;
  if (check) {
    if (existsSync(lyDir)) {
      const r = Bun.spawnSync(["git", "-C", lyDir, "rev-parse", "--short", "HEAD"], { stdout: "pipe" });
      logInfo(`ly: ${new TextDecoder().decode(r.stdout).trim()}`);
    } else {
      logInfo("ly: not cloned");
    }
    return true;
  }

  let headChanged = true;

  if (!existsSync(lyDir)) {
    logInfo("ly: cloning…");
    const r = Bun.spawnSync(["git", "clone", "--recurse-submodules", lyRepo, lyDir], { stdout: "inherit", stderr: "inherit" });
    if (r.exitCode !== 0) { logError("ly: clone failed"); return false; }
  } else {
    const headBefore = new TextDecoder().decode(
      Bun.spawnSync(["git", "-C", lyDir, "rev-parse", "HEAD"], { stdout: "pipe" }).stdout
    ).trim();

    logInfo("ly: fetching…");
    const subR = Bun.spawnSync(
      ["git", "-C", lyDir, "submodule", "update", "--init", "--recursive", "-q"],
      { stdout: "pipe", stderr: "pipe" }
    );
    if (subR.exitCode !== 0) {
      const err = new TextDecoder().decode(subR.stderr).trim().split("\n").slice(0, 5).join("\n");
      logError(`ly: submodule update failed\n${err}`);
      return false;
    }

    const pullR = Bun.spawnSync(
      ["git", "-C", lyDir, "pull", "-q", "--ff-only"],
      { stdout: "pipe", stderr: "pipe" }
    );
    if (pullR.exitCode !== 0) {
      const err = new TextDecoder().decode(pullR.stderr).trim().split("\n").slice(0, 5).join("\n");
      logError(`ly: git pull failed\n${err}`);
      return false;
    }

    const headAfter = new TextDecoder().decode(
      Bun.spawnSync(["git", "-C", lyDir, "rev-parse", "HEAD"], { stdout: "pipe" }).stdout
    ).trim();
    headChanged = headBefore !== headAfter;
  }

  const lyInstalled = commandExists("ly") || existsSync("/usr/bin/ly");
  if (!headChanged && lyInstalled) {
    const lyTag = new TextDecoder().decode(
      Bun.spawnSync(["git", "-C", lyDir, "describe", "--tags", "--abbrev=0"], { stdout: "pipe", stderr: "pipe" }).stdout
    ).trim();
    logSuccess(`ly: up to date${lyTag ? ` (${lyTag})` : ""}`);
    return true;
  }

  logInfo("ly: building…");
  const build = Bun.spawnSync([zigCmd, "build"], { cwd: lyDir, stdout: "pipe", stderr: "pipe" });
  if (build.exitCode !== 0) {
    process.stderr.write(build.stderr);
    logError("ly: build failed");
    return false;
  }
  const priv = commandExists("doas") ? "doas" : "sudo";
  Bun.spawnSync([priv, zigCmd, "build", "installnoconf"], { cwd: lyDir, stdout: "inherit", stderr: "inherit" });
  const lyVer = getVersion("ly", ["-v"]);
  logSuccess(`ly: ${lyVer || "installed"}`);
  return true;
}

async function updateZinit(check: boolean): Promise<boolean> {
  const zinitDir = join(HOME_DIR, ".local/share/zinit");
  if (!existsSync(zinitDir) || !commandExists("zsh")) return true;
  const src = `source ${zinitDir}/zinit.git/zinit.zsh`;
  if (check) { logInfo(`zinit: ${zinitDir}`); return true; }
  Bun.spawnSync(["zsh", "-c", `${src} && zinit self-update`], { stdout: "inherit", stderr: "inherit" });
  Bun.spawnSync(["zsh", "-c", `${src} && zinit update --all`], { stdout: "inherit", stderr: "inherit" });
  return true;
}

function getInstalledXbpsVersion(pkg: string): string | null {
  const r = Bun.spawnSync(["xbps-query", "-p", "pkgver", pkg], { stdout: "pipe", stderr: "pipe" });
  if (r.exitCode !== 0) return null;
  const pkgver = new TextDecoder().decode(r.stdout).trim();
  const match = pkgver.match(/^.+-(\d[\d.]+)_\d+$/);
  return match?.[1] ?? null;
}

function getTemplateVersion(buildScript: string): string | null {
  const r = Bun.spawnSync(["grep", "-m1", "^VERSION=", buildScript], { stdout: "pipe" });
  const line = new TextDecoder().decode(r.stdout).trim();
  return line ? line.replace(/^VERSION=["']?/, "").replace(/["']?$/, "") : null;
}

async function updateXbpsBuilds(check: boolean): Promise<boolean> {
  if (!commandExists("xbps-create")) { logWarn("xbps-create: not found, skipping"); return true; }
  if (!existsSync(PKGBUILDS_DIR)) return true;

  const entries = await readdir(PKGBUILDS_DIR, { withFileTypes: true });
  let ok = true;
  for (const entry of entries.filter((e) => e.isDirectory())) {
    const name = entry.name;
    const buildScript = join(PKGBUILDS_DIR, name, "build.sh");
    if (!existsSync(buildScript)) continue;

    const installed = getInstalledXbpsVersion(name);
    const template = getTemplateVersion(buildScript);

    if (check) {
      logInfo(`${name}: installed=${installed ?? "not installed"} template=${template ?? "unknown"}`);
      continue;
    }

    if (installed && template && installed === template) {
      logInfo(`${name}: up to date (${installed})`);
      continue;
    }

    logInfo(`${name}: building ${template}…`);
    const cacheDir = join(CACHE_DIR, name);
    const result = Bun.spawnSync(["bash", buildScript, cacheDir], { stdout: "inherit", stderr: "inherit" });
    if (result.exitCode !== 0) { logError(`${name}: build failed`); ok = false; }
  }
  return ok;
}

// ─── registry ────────────────────────────────────────────────────────────────

const UPDATERS: Updater[] = [
  { name: "xbps",       group: "system", run: updateXbps },
  { name: "pacman",     group: "system", run: updatePacman },
  { name: "yay",        group: "system", run: updateYay },
  { name: "flatpak",    group: "system", run: updateFlatpak },
  { name: "bun",        group: "system", run: updateBunSelf },
  { name: "deno",       group: "system", run: updateDeno },
  { name: "rustup",     group: "system", run: updateRustup },
  { name: "npm",        group: "global", run: updateNpm },
  { name: "bun-global", group: "global", run: updateBunGlobal },
  { name: "yarn",       group: "global", run: updateYarn },
  { name: "pnpm",       group: "global", run: updatePnpm },
  { name: "pipx",       group: "global", run: updatePipx },
  { name: "cargo",      group: "global", run: updateCargo },
  { name: "pkgbuilds",  group: "source", run: updateXbpsBuilds },
  { name: "fnm",        group: "source", run: updateFnm },
  { name: "anyzig",     group: "source", run: updateAnyzig },
  { name: "ly",         group: "source", run: updateLy },
  { name: "zinit",      group: "source", run: updateZinit },
];

async function runGroup(group: "system" | "global" | "source", check: boolean): Promise<boolean> {
  let ok = true;
  for (const u of UPDATERS.filter((u) => u.group === group)) {
    if (!await u.run(check)) ok = false;
  }
  return ok;
}

// ─── helpers ─────────────────────────────────────────────────────────────────

function kernelHint() {
  if (!commandExists("vkpurge")) return;
  const raw = Bun.spawnSync(["vkpurge", "list"], { stdout: "pipe", stderr: "pipe" });
  const all = new TextDecoder().decode(raw.stdout).trim().split("\n").filter(Boolean);
  const voidKernels = all.filter((k) => !k.startsWith("linux"));
  const toRemove = voidKernels.length - 2;
  if (toRemove > 0) {
    logWarn(`${toRemove} old Void kernel${toRemove > 1 ? "s" : ""} can be cleaned → run: dot kernel`);
  }
}

function showInfo() {
  console.log("\nRuntimes:");
  const tools: [string, string[]][] = [
    ["node", ["--version"]], ["fnm", ["--version"]], ["python3", ["--version"]],
    ["rustc", ["--version"]], ["go", ["version"]], ["deno", ["--version"]], ["bun", ["--version"]],
  ];
  for (const [cmd, args] of tools) {
    if (commandExists(cmd)) logInfo(`${cmd}: ${getVersion(cmd, args)}`);
  }
  if (existsSync(join(HOME_DIR, ".local/bin/zig"))) logInfo("zig: installed (anyzig)");

  console.log("\nPackage managers:");
  for (const pm of ["xbps-install", "flatpak", "npm", "bun", "yarn", "pnpm", "pipx", "cargo"]) {
    if (commandExists(pm)) logInfo(`  ${pm}`);
  }
}

async function withAI(rawArgs: string[], subCmd: string | null, run: () => Promise<boolean>): Promise<boolean> {
  if (!rawArgs.includes("--ai")) return run();
  const filteredArgs = rawArgs.filter((a) => a !== "--ai");
  const base = [process.execPath, process.argv[1], "update"];
  const cmdArgs = subCmd ? [...base, subCmd, ...filteredArgs] : [...base, ...filteredArgs];
  const output = await captureAndStream(cmdArgs);
  await analyzeWithAI(output);
  return true;
}

// ─── subcommands ─────────────────────────────────────────────────────────────

const checkFlag = { type: "boolean" as const, description: "Show what would update without making changes" };
const aiFlag = { type: "boolean" as const, description: "Analyse output with AI after completion" };

export const systemUpdateCommand = defineCommand({
  meta: { description: "Update system packages (xbps/pacman+yay/brew, flatpak) and self-updating runtimes" },
  args: { check: checkFlag, ai: aiFlag },
  async run({ args, rawArgs }) {
    const check = args.check ?? false;
    const ok = await withAI(rawArgs, "system", async () => {
      const distro = detectDistro();
      const pm = distro === "void" ? "xbps" : distro === "arch" ? "pacman + yay" : distro === "macos" ? "brew" : "system packages";
      logDesc(`Updates system packages via ${pm}, flatpak, bun, deno, and rustup.`);
      const result = await runGroup("system", check);
      if (!check) kernelHint();
      return result;
    });
    if (!ok) process.exit(1);
  },
});

export const globalUpdateCommand = defineCommand({
  meta: { description: "Update global package manager packages (npm, bun, pipx, cargo…)" },
  args: { check: checkFlag, ai: aiFlag },
  async run({ args, rawArgs }) {
    const check = args.check ?? false;
    const ok = await withAI(rawArgs, "global", async () => {
      logDesc("Updates global packages via npm, bun, yarn, pnpm, pipx, and cargo.");
      return runGroup("global", check);
    });
    if (!ok) process.exit(1);
  },
});

export const sourceUpdateCommand = defineCommand({
  meta: { description: "Update source/custom-built tools (pkgbuilds, fnm, anyzig, ly, zinit)" },
  args: { check: checkFlag, ai: aiFlag },
  async run({ args, rawArgs }) {
    const check = args.check ?? false;
    const ok = await withAI(rawArgs, "source", async () => {
      logDesc("Builds and updates source tools: pkgbuilds, fnm, anyzig, ly, and zinit.");
      logSection("source tools");
      return runGroup("source", check);
    });
    if (!ok) process.exit(1);
  },
});

export const updateCommand = defineCommand({
  meta: { description: "Update system and packages" },
  args: {
    all: { type: "boolean", description: "Update system + global + source" },
    check: checkFlag,
    info: { type: "boolean", description: "Show installed versions without updating" },
    ai: aiFlag,
  },
  subCommands: {
    system: systemUpdateCommand,
    global: globalUpdateCommand,
    source: sourceUpdateCommand,
  },
  async run({ args, rawArgs }) {
    if (rawArgs.some((a: string) => !a.startsWith("-"))) return;
    if (args.info) { showInfo(); return; }
    if (args.all || args.check) {
      const check = args.check ?? false;
      const ok = await withAI(rawArgs, null, async () => {
        let ok = true;
        for (const group of ["system", "global", "source"] as const) {
          if (group === "source") logSection("source tools");
          if (!await runGroup(group, check)) ok = false;
        }
        if (!check) kernelHint();
        return ok;
      });
      if (!ok) process.exit(1);
      return;
    }
    console.log(`
Usage: dot update <subcommand> [--check]

Subcommands:
  system    Update xbps (Void) / pacman+yay (Arch), flatpak, bun, deno, rustup
  global    Update npm -g, bun -g, yarn, pnpm, pipx, cargo
  source    Update pkgbuilds, fnm, anyzig, ly, zinit

Flags:
  --all     Run all three subcommands
  --check   Show what would update without making changes
  --info    Show currently installed versions
  --ai      Analyse output with AI after completion

Examples:
  dot update system
  dot update --all
  dot update --all --ai
  dot update system --ai
  dot update --check
  dot update --info
`);
  },
});
