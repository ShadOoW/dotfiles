import { defineCommand } from "citty";
import { existsSync } from "fs";
import { readdir } from "fs/promises";
import { join } from "path";
import { HOME_DIR, PKGBUILDS_DIR, CACHE_DIR } from "../lib/config.ts";
import { commandExists, getVersion, logError, logInfo, logSection, logSuccess, logWarn } from "../lib/console.ts";
import { analyzeWithAI, captureAndStream } from "../lib/ai.ts";

// ─── individual updaters ────────────────────────────────────────────────────

async function updateXbps(check: boolean) {
  if (!commandExists("xbps-install")) { logWarn("xbps: not found, skipping"); return; }
  if (check) {
    logInfo(`xbps: ${getVersion("xbps-query", ["--version"])}`);
    return;
  }
  logInfo("xbps: syncing and upgrading…");
  Bun.spawnSync(["sudo", "xbps-install", "-Syu"], { stdout: "inherit", stderr: "inherit" });
}

async function updateFlatpak(check: boolean) {
  if (!commandExists("flatpak")) return;
  if (check) { logInfo(`flatpak: ${getVersion("flatpak", ["--version"])}`); return; }
  Bun.spawnSync(["flatpak", "update", "-y"], { stdout: "inherit", stderr: "inherit" });
}

async function updateBunSelf(check: boolean) {
  if (!commandExists("bun")) return;
  if (check) { logInfo(`bun: ${getVersion("bun", ["--version"])}`); return; }
  Bun.spawnSync(["bun", "upgrade"], { stdout: "inherit", stderr: "inherit" });
}

async function updateDeno(check: boolean) {
  if (!commandExists("deno")) return;
  if (check) { logInfo(`deno: ${getVersion("deno", ["--version"])}`); return; }
  Bun.spawnSync(["deno", "upgrade"], { stdout: "inherit", stderr: "inherit" });
}

async function updateRustup(check: boolean) {
  if (!commandExists("rustup")) return;
  if (check) { logInfo(`rustup: ${getVersion("rustup", ["--version"])}`); return; }
  Bun.spawnSync(["rustup", "update"], { stdout: "inherit", stderr: "inherit" });
}

async function updateNpm(check: boolean) {
  if (!commandExists("npm")) return;
  if (check) { logInfo(`npm: ${getVersion("npm", ["--version"])}`); return; }
  Bun.spawnSync(["npm", "update", "-g"], { stdout: "inherit", stderr: "inherit" });
}

async function updateBunGlobal(check: boolean) {
  if (!commandExists("bun")) return;
  if (check) { logInfo(`bun -g: ${getVersion("bun", ["outdated", "-g"])}`); return; }
  Bun.spawnSync(["bun", "update", "-g"], { stdout: "inherit", stderr: "inherit" });
}

async function updateYarn(check: boolean) {
  if (!commandExists("yarn")) return;
  if (check) { logInfo("yarn: checking global packages…"); return; }
  Bun.spawnSync(["yarn", "global", "upgrade"], { stdout: "inherit", stderr: "inherit" });
}

async function updatePnpm(check: boolean) {
  if (!commandExists("pnpm")) return;
  if (check) { logInfo(`pnpm: ${getVersion("pnpm", ["--version"])}`); return; }
  Bun.spawnSync(["pnpm", "update", "-g"], { stdout: "inherit", stderr: "inherit" });
}

async function updatePipx(check: boolean) {
  if (!commandExists("pipx")) return;
  if (check) { logInfo("pipx: listing packages…"); Bun.spawnSync(["pipx", "list"], { stdout: "inherit" }); return; }
  Bun.spawnSync(["pipx", "upgrade-all"], { stdout: "inherit", stderr: "inherit" });
}

async function updateCargo(check: boolean) {
  if (!commandExists("cargo")) return;
  if (!commandExists("cargo-install-update")) {
    logWarn("cargo-install-update not found — install with: cargo install cargo-install-update");
    return;
  }
  if (check) { Bun.spawnSync(["cargo", "install-update", "--dry-run"], { stdout: "inherit" }); return; }
  Bun.spawnSync(["cargo", "install-update", "-a"], { stdout: "inherit", stderr: "inherit" });
}

async function updateFnm(check: boolean) {
  if (!commandExists("cargo")) { logWarn("fnm: cargo not found, skipping"); return; }
  if (check) { logInfo(`fnm: ${getVersion("fnm", ["--version"])}`); return; }
  logInfo("fnm: updating via cargo…");
  const fnmResult = Bun.spawnSync(["cargo", "install", "fnm"], { stdout: "pipe", stderr: "pipe" });
  if (fnmResult.exitCode !== 0) {
    process.stderr.write(fnmResult.stderr);
    logError("fnm: install failed");
  } else {
    logSuccess("fnm: up to date");
  }
}

async function updatePacman(check: boolean) {
  if (!commandExists("pacman")) return;
  if (check) { logInfo(`pacman: ${getVersion("pacman", ["--version"])}`); return; }
  const priv = commandExists("doas") ? "doas" : "sudo";
  logInfo("pacman: syncing and upgrading…");
  Bun.spawnSync([priv, "pacman", "-Syu", "--noconfirm"], { stdout: "inherit", stderr: "inherit" });
}

async function updateAnyzig(check: boolean) {
  const zigPath = join(HOME_DIR, ".local/bin/zig");
  if (!existsSync(zigPath) && !commandExists("zig")) return;
  const url = "https://github.com/marler8997/anyzig/releases/download/v2026_03_26/anyzig-x86_64-linux.tar.gz";
  if (check) { logInfo(`anyzig: ${existsSync(zigPath) ? "installed" : "not found"}`); return; }

  const tmpR = Bun.spawnSync(["mktemp", "/tmp/anyzig.tar.gz.XXXXXX"], { stdout: "pipe" });
  const tmpfile = new TextDecoder().decode(tmpR.stdout).trim();
  logInfo("anyzig: downloading…");
  Bun.spawnSync(["curl", "-fsSL", url, "-o", tmpfile], { stdout: "pipe", stderr: "pipe" });
  Bun.spawnSync(["tar", "-xzf", tmpfile, "-C", join(HOME_DIR, ".local/bin")], { stdout: "pipe" });
  Bun.spawnSync(["chmod", "+x", zigPath]);
  Bun.spawnSync(["rm", "-f", tmpfile]);
  logInfo("anyzig: updated");
}

async function updateLy(check: boolean) {
  const lyDir = join(HOME_DIR, ".builds/ly");
  const lyRepo = "https://codeberg.org/fairyglade/ly.git";
  const zigCmd = existsSync(join(HOME_DIR, ".local/bin/zig")) ? join(HOME_DIR, ".local/bin/zig") : "zig";

  if (!commandExists("git")) return;
  if (check) {
    if (existsSync(lyDir)) {
      const r = Bun.spawnSync(["git", "-C", lyDir, "rev-parse", "--short", "HEAD"], { stdout: "pipe" });
      logInfo(`ly: ${new TextDecoder().decode(r.stdout).trim()}`);
    } else {
      logInfo("ly: not cloned");
    }
    return;
  }

  let headChanged = true;

  if (!existsSync(lyDir)) {
    logInfo("ly: cloning…");
    Bun.spawnSync(["git", "clone", "--recurse-submodules", lyRepo, lyDir], { stdout: "inherit", stderr: "inherit" });
  } else {
    const headBefore = new TextDecoder().decode(
      Bun.spawnSync(["git", "-C", lyDir, "rev-parse", "HEAD"], { stdout: "pipe" }).stdout
    ).trim();

    logInfo("ly: updating…");
    Bun.spawnSync(["git", "-C", lyDir, "submodule", "update", "--init", "--recursive", "-q"], { stdout: "pipe" });
    Bun.spawnSync(["git", "-C", lyDir, "pull", "-q", "--ff-only"], { stdout: "pipe" });

    const headAfter = new TextDecoder().decode(
      Bun.spawnSync(["git", "-C", lyDir, "rev-parse", "HEAD"], { stdout: "pipe" }).stdout
    ).trim();

    headChanged = headBefore !== headAfter;
  }

  const lyInstalled = commandExists("ly") || existsSync("/usr/bin/ly");
  if (!headChanged && lyInstalled) { logInfo("ly: up to date"); return; }

  logInfo("ly: building…");
  const build = Bun.spawnSync([zigCmd, "build"], { cwd: lyDir, stdout: "pipe", stderr: "pipe" });
  if (build.exitCode !== 0) {
    process.stderr.write(build.stderr);
    logError("ly: build failed");
    return;
  }
  const priv = commandExists("doas") ? "doas" : "sudo";
  Bun.spawnSync([priv, zigCmd, "build", "installnoconf"], { cwd: lyDir, stdout: "inherit", stderr: "inherit" });
}

async function updateZinit(check: boolean) {
  const zinitDir = join(HOME_DIR, ".local/share/zinit");
  if (!existsSync(zinitDir) || !commandExists("zsh")) return;
  const src = `source ${zinitDir}/zinit.git/zinit.zsh`;
  if (check) { logInfo(`zinit: ${zinitDir}`); return; }
  Bun.spawnSync(["zsh", "-c", `${src} && zinit self-update`], { stdout: "inherit", stderr: "inherit" });
  Bun.spawnSync(["zsh", "-c", `${src} && zinit update --all`], { stdout: "inherit", stderr: "inherit" });
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

function getInstalledXbpsVersion(pkg: string): string | null {
  const r = Bun.spawnSync(["xbps-query", "-p", "pkgver", pkg], { stdout: "pipe", stderr: "pipe" });
  if (r.exitCode !== 0) return null;
  const pkgver = new TextDecoder().decode(r.stdout).trim(); // e.g. "antigravity-1.23.2_1"
  const match = pkgver.match(/^.+-(\d[\d.]+)_\d+$/);
  return match?.[1] ?? null;
}

function getTemplateVersion(buildScript: string): string | null {
  const r = Bun.spawnSync(["grep", "-m1", "^VERSION=", buildScript], { stdout: "pipe" });
  const line = new TextDecoder().decode(r.stdout).trim();
  return line ? line.replace(/^VERSION=["']?/, "").replace(/["']?$/, "") : null;
}

async function updateXbpsBuilds(check: boolean) {
  if (!commandExists("xbps-create")) { logWarn("xbps-create: not found, skipping"); return; }
  if (!existsSync(PKGBUILDS_DIR)) return;

  const entries = await readdir(PKGBUILDS_DIR, { withFileTypes: true });
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
    if (result.exitCode !== 0) logError(`${name}: build failed`);
  }
}

// ─── subcommands ─────────────────────────────────────────────────────────────

const checkFlag = { type: "boolean" as const, description: "Show what would update without making changes" };
const aiFlag = { type: "boolean" as const, description: "Analyse output with AI after completion" };

async function withAI(rawArgs: string[], subCmd: string | null, run: () => Promise<void>) {
  if (!rawArgs.includes("--ai")) { await run(); return; }
  const filteredArgs = rawArgs.filter((a) => a !== "--ai");
  const base = [process.execPath, process.argv[1], "update"];
  const cmdArgs = subCmd ? [...base, subCmd, ...filteredArgs] : [...base, ...filteredArgs];
  const output = await captureAndStream(cmdArgs);
  await analyzeWithAI(output);
}

export const systemUpdateCommand = defineCommand({
  meta: { description: "Update system packages (xbps/pacman, flatpak) and self-updating runtimes" },
  args: { check: checkFlag, ai: aiFlag },
  async run({ args, rawArgs }) {
    await withAI(rawArgs, "system", async () => {
      logSection("System");
      await updateXbps(args.check ?? false);
      await updatePacman(args.check ?? false);
      await updateFlatpak(args.check ?? false);
      await updateBunSelf(args.check ?? false);
      await updateDeno(args.check ?? false);
      await updateRustup(args.check ?? false);
    });
  },
});

export const globalUpdateCommand = defineCommand({
  meta: { description: "Update global package manager packages (npm, bun, pipx, cargo…)" },
  args: { check: checkFlag, ai: aiFlag },
  async run({ args, rawArgs }) {
    await withAI(rawArgs, "global", async () => {
      logSection("Global packages");
      await updateNpm(args.check ?? false);
      await updateBunGlobal(args.check ?? false);
      await updateYarn(args.check ?? false);
      await updatePnpm(args.check ?? false);
      await updatePipx(args.check ?? false);
      await updateCargo(args.check ?? false);
    });
  },
});

export const sourceUpdateCommand = defineCommand({
  meta: { description: "Update source/custom-built tools (pkgbuilds, fnm, anyzig, ly, zinit)" },
  args: { check: checkFlag, ai: aiFlag },
  async run({ args, rawArgs }) {
    await withAI(rawArgs, "source", async () => {
      logSection("Source-built tools");
      await updateXbpsBuilds(args.check ?? false);
      await updateFnm(args.check ?? false);
      await updateAnyzig(args.check ?? false);
      await updateLy(args.check ?? false);
      await updateZinit(args.check ?? false);
    });
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
    if (rawArgs.some((a: string) => !a.startsWith("-"))) return; // subcommand is handling it
    if (args.info) { showInfo(); return; }
    if (args.all || args.check) {
      const runAll = async () => {
        logSection("System");
        await updateXbps(args.check ?? false);
        await updatePacman(args.check ?? false);
        await updateFlatpak(args.check ?? false);
        await updateBunSelf(args.check ?? false);
        await updateDeno(args.check ?? false);
        await updateRustup(args.check ?? false);
        logSection("Global packages");
        await updateNpm(args.check ?? false);
        await updateBunGlobal(args.check ?? false);
        await updateYarn(args.check ?? false);
        await updatePnpm(args.check ?? false);
        await updatePipx(args.check ?? false);
        await updateCargo(args.check ?? false);
        logSection("Source-built tools");
        await updateXbpsBuilds(args.check ?? false);
        await updateFnm(args.check ?? false);
        await updateAnyzig(args.check ?? false);
        await updateLy(args.check ?? false);
        await updateZinit(args.check ?? false);
      };
      await withAI(rawArgs, null, runAll);
      return;
    }
    console.log(`
Usage: dot update <subcommand> [--check]

Subcommands:
  system    Update xbps/pacman, flatpak, bun, deno, rustup
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
