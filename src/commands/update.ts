import { defineCommand } from "citty";
import { existsSync } from "fs";
import { join } from "path";
import { HOME_DIR } from "../lib/config.ts";
import { commandExists, getVersion, logError, logInfo, logSection, logWarn } from "../lib/console.ts";

// ─── individual updaters ────────────────────────────────────────────────────

async function updateXbps(check: boolean) {
  if (!commandExists("xbps-install")) { logWarn("xbps: not found, skipping"); return; }
  if (check) {
    logInfo(`xbps: ${getVersion("xbps-query", ["--version"])}`);
    return;
  }
  logInfo("xbps: syncing…");
  Bun.spawnSync(["sudo", "xbps-install", "-S"], { stdout: "inherit", stderr: "inherit" });
  logInfo("xbps: upgrading…");
  Bun.spawnSync(["sudo", "xbps-install", "-Su"], { stdout: "inherit", stderr: "inherit" });
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
  Bun.spawnSync(["cargo", "install", "fnm"], { stdout: "inherit", stderr: "inherit" });
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
  Bun.spawnSync(["curl", "-L", url, "-o", tmpfile], { stdout: "inherit", stderr: "inherit" });
  Bun.spawnSync(["tar", "-xzf", tmpfile, "-C", join(HOME_DIR, ".local/bin")], { stdout: "inherit" });
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

  if (!existsSync(lyDir)) {
    logInfo("ly: cloning…");
    Bun.spawnSync(["git", "clone", "--recurse-submodules", lyRepo, lyDir], { stdout: "inherit", stderr: "inherit" });
  } else {
    logInfo("ly: updating…");
    Bun.spawnSync(["git", "-C", lyDir, "submodule", "update", "--init", "--recursive"], { stdout: "inherit" });
    Bun.spawnSync(["git", "-C", lyDir, "pull"], { stdout: "inherit" });
  }

  if (commandExists("ly") || existsSync("/usr/bin/ly")) { logInfo("ly: already installed"); return; }

  logInfo("ly: building…");
  const build = Bun.spawnSync([zigCmd, "build", `--build-file=${lyDir}/build.zig`], { stdout: "pipe", stderr: "pipe" });
  if (build.exitCode !== 0) { logError("ly: build failed"); return; }
  const priv = commandExists("doas") ? "doas" : "sudo";
  Bun.spawnSync([priv, zigCmd, "build", "installnoconf", `--build-file=${lyDir}/build.zig`], { stdout: "inherit", stderr: "inherit" });
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

// ─── subcommands ─────────────────────────────────────────────────────────────

const checkFlag = { type: "boolean" as const, description: "Show what would update without making changes" };

export const systemUpdateCommand = defineCommand({
  meta: { description: "Update system packages (xbps/pacman, flatpak) and self-updating runtimes" },
  args: { check: checkFlag },
  async run({ args }) {
    logSection("System");
    await updateXbps(args.check ?? false);
    await updatePacman(args.check ?? false);
    await updateFlatpak(args.check ?? false);
    await updateBunSelf(args.check ?? false);
    await updateDeno(args.check ?? false);
    await updateRustup(args.check ?? false);
  },
});

export const globalUpdateCommand = defineCommand({
  meta: { description: "Update global package manager packages (npm, bun, pipx, cargo…)" },
  args: { check: checkFlag },
  async run({ args }) {
    logSection("Global packages");
    await updateNpm(args.check ?? false);
    await updateBunGlobal(args.check ?? false);
    await updateYarn(args.check ?? false);
    await updatePnpm(args.check ?? false);
    await updatePipx(args.check ?? false);
    await updateCargo(args.check ?? false);
  },
});

export const sourceUpdateCommand = defineCommand({
  meta: { description: "Update git/source-built tools (fnm, anyzig, ly, zinit)" },
  args: { check: checkFlag },
  async run({ args }) {
    logSection("Source-built tools");
    await updateFnm(args.check ?? false);
    await updateAnyzig(args.check ?? false);
    await updateLy(args.check ?? false);
    await updateZinit(args.check ?? false);
  },
});

export const updateCommand = defineCommand({
  meta: { description: "Update system and packages" },
  args: {
    all: { type: "boolean", description: "Update system + global + source" },
    check: checkFlag,
    info: { type: "boolean", description: "Show installed versions without updating" },
  },
  subCommands: {
    system: systemUpdateCommand,
    global: globalUpdateCommand,
    source: sourceUpdateCommand,
  },
  async run({ args }) {
    if (args.info) { showInfo(); return; }
    if (args.all || args.check) {
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
      await updateFnm(args.check ?? false);
      await updateAnyzig(args.check ?? false);
      await updateLy(args.check ?? false);
      await updateZinit(args.check ?? false);
      return;
    }
    console.log(`
Usage: dot update <subcommand> [--check]

Subcommands:
  system    Update xbps/pacman, flatpak, bun, deno, rustup
  global    Update npm -g, bun -g, yarn, pnpm, pipx, cargo
  source    Update fnm, anyzig, ly, zinit

Flags:
  --all     Run all three subcommands
  --check   Show what would update without making changes
  --info    Show currently installed versions

Examples:
  dot update system
  dot update --all
  dot update --check
  dot update --info
`);
  },
});
