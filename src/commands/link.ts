import { defineCommand } from "citty";
import { confirm } from "@clack/prompts";
import { existsSync, lstatSync, readlinkSync } from "fs";
import { mkdir, rm, symlink, unlink } from "fs/promises";
import { dirname, join } from "path";
import { PACKAGES_DIR } from "../lib/config.ts";
import {
  collectFiles,
  detectInit,
  getPackageMeta,
  hasInitDirs,
  isAlreadyLinked,
  listPackages,
} from "../lib/pkg.ts";
import { colors, logError, logInfo, logSuccess, logWarn } from "../lib/console.ts";

async function ensureSudo(): Promise<boolean> {
  const r = Bun.spawnSync(["sudo", "-v"], { stdout: "ignore", stderr: "ignore" });
  return r.exitCode === 0;
}

async function linkPackage(pkg: string, initOverride?: string, dryRun = false): Promise<void> {
  const pkgDir = join(PACKAGES_DIR, pkg);
  if (!existsSync(pkgDir)) {
    logError(`Package "${pkg}" not found in packages/`);
    return;
  }

  const hasHome = existsSync(join(pkgDir, "home"));
  const hasSystem = existsSync(join(pkgDir, "system"));

  if (!hasHome && !hasSystem) {
    logWarn(`Package "${pkg}" has no home/ or system/ directory — nothing to link`);
    return;
  }

  let resolvedInit = initOverride;
  if (hasSystem && !resolvedInit) {
    const { runit, systemd } = hasInitDirs(pkgDir);
    if (runit || systemd) {
      const detected = detectInit();
      if (detected) {
        resolvedInit = detected;
        logInfo(`${pkg}: auto-detected init system: ${detected}`);
      } else {
        logError(`Package "${pkg}" has init-specific configs. Specify --init:`);
        if (runit) console.error(`  dot link ${pkg} --init runit`);
        if (systemd) console.error(`  dot link ${pkg} --init systemd`);
        return;
      }
    }
  }

  let sudoCached = false;

  if (hasHome) {
    const files = await collectFiles(pkgDir, "home");
    if (files.length > 0) {
      logInfo(`Linking home files for ${colors.bold(pkg)}…`);
      let count = 0;
      for (const { source, target } of files) {
        if (isAlreadyLinked(source, target)) {
          console.log(`  ${colors.dim("already")} ${target}`);
          continue;
        }
        if (dryRun) {
          console.log(`  ${colors.cyan("would →")} ${target}`);
          count++;
          continue;
        }
        try {
          await mkdir(dirname(target), { recursive: true });
          if (existsSync(target)) await rm(target, { recursive: true });
          await symlink(source, target);
          console.log(`  ${colors.green("→")} ${target}`);
          count++;
        } catch (e) {
          logError(`  Failed to link ${target}: ${e}`);
        }
      }
      if (dryRun) logInfo(`Would link ${count} home file(s)`);
      else logSuccess(`Linked ${count} home file(s)`);
    }
  }

  if (hasSystem) {
    const files = await collectFiles(pkgDir, "system", resolvedInit);
    if (files.length > 0) {
      if (!dryRun && !sudoCached) {
        if (!(await ensureSudo())) {
          logError("sudo required for system files");
          return;
        }
        sudoCached = true;
      }
      logInfo(`Linking system files for ${colors.bold(pkg)}…`);
      let count = 0;
      for (const { source, target } of files) {
        if (isAlreadyLinked(source, target)) {
          console.log(`  ${colors.dim("already")} ${target}`);
          continue;
        }
        if (dryRun) {
          console.log(`  ${colors.cyan("would →")} ${target}`);
          count++;
          continue;
        }
        try {
          Bun.spawnSync(["sudo", "mkdir", "-p", dirname(target)]);
          Bun.spawnSync(["sudo", "rm", "-rf", target]);
          Bun.spawnSync(["sudo", "ln", "-sf", source, target]);
          console.log(`  ${colors.green("→")} ${target}`);
          count++;
        } catch (e) {
          logError(`  Failed to link ${target}: ${e}`);
        }
      }
      if (dryRun) logInfo(`Would link ${count} system file(s)`);
      else logSuccess(`Linked ${count} system file(s)`);
    }
  }
}

function printLinkUsage() {
  console.log(`
Usage: dot link <package> [--init runit|systemd] [--dry-run]
       dot link --tag <tag> [--init runit|systemd] [--dry-run]

Links a package's config files into their target locations.
Home files (~/) are linked without sudo. System files (/) prompt for sudo.
Init system is auto-detected when not specified.

Examples:
  dot link zsh
  dot link zram
  dot link ly --init runit
  dot link --tag wayland
  dot link nvim --dry-run

Run ${colors.cyan("dot link")} without args to see available packages.
`);
}

export const linkCommand = defineCommand({
  meta: { description: "Symlink a package's config files into their target locations" },
  args: {
    init: { type: "string", description: "Init system: runit or systemd (auto-detected if omitted)" },
    "dry-run": { type: "boolean", default: false, description: "Show what would be linked without doing it" },
    tag: { type: "string", description: "Link all packages with this tag" },
  },
  async run({ args, rawArgs }) {
    const dryRun = args["dry-run"] ?? false;

    if (args.tag) {
      const allPkgs = await listPackages();
      const tagged: string[] = [];
      for (const name of allPkgs) {
        const meta = await getPackageMeta(name);
        if (meta?.tags.includes(args.tag)) tagged.push(name);
      }
      if (tagged.length === 0) {
        logWarn(`No packages found with tag "${args.tag}"`);
        return;
      }
      logInfo(`Packages tagged "${args.tag}": ${tagged.join(", ")}`);
      if (dryRun) logInfo("Dry run — no changes will be made");
      for (const name of tagged) {
        await linkPackage(name, args.init, dryRun);
      }
      return;
    }

    const pkg = rawArgs.find((a) => !a.startsWith("-"));
    if (!pkg) {
      const pkgs = await listPackages();
      printLinkUsage();
      console.log(`Available packages:\n  ${pkgs.join("  ")}\n`);
      process.exit(0);
    }

    if (dryRun) logInfo("Dry run — no changes will be made");
    await linkPackage(pkg, args.init, dryRun);
  },
});

export const unlinkCommand = defineCommand({
  meta: { description: "Remove symlinks created by dot link" },
  args: {
    init: { type: "string", description: "Init system: runit or systemd" },
    yes: { type: "boolean", short: "y", default: false, description: "Skip confirmation" },
  },
  async run({ args, rawArgs }) {
    const pkg = rawArgs.find((a) => !a.startsWith("-"));
    if (!pkg) {
      const pkgs = await listPackages();
      console.log(`\nUsage: dot unlink <package>\n\nAvailable packages:\n  ${pkgs.join("  ")}\n`);
      process.exit(0);
    }

    const pkgDir = join(PACKAGES_DIR, pkg);
    if (!existsSync(pkgDir)) {
      logError(`Package "${pkg}" not found`);
      process.exit(1);
    }

    let resolvedInit = args.init;
    if (!resolvedInit) {
      const { runit, systemd } = hasInitDirs(pkgDir);
      if (runit || systemd) resolvedInit = detectInit() ?? undefined;
    }

    const hasHome = existsSync(join(pkgDir, "home"));
    const hasSystem = existsSync(join(pkgDir, "system"));
    const homeFiles = hasHome ? await collectFiles(pkgDir, "home") : [];
    const systemFiles = hasSystem ? await collectFiles(pkgDir, "system", resolvedInit) : [];
    const allFiles = [...homeFiles, ...systemFiles];

    if (allFiles.length === 0) {
      logWarn(`No files to unlink for "${pkg}"`);
      return;
    }

    console.log(`\nWill remove ${allFiles.length} symlink(s) for ${colors.bold(pkg)}:`);
    for (const { target } of allFiles) {
      if (existsSync(target)) console.log(`  ${colors.red("✗")} ${target}`);
    }

    const answer = args.yes || await confirm({ message: "Proceed?" });
    if (!answer) { console.log("Cancelled."); return; }

    let sudoCached = false;
    let count = 0;

    for (const { source, target } of allFiles) {
      try {
        const isSymlink = existsSync(target) && lstatSync(target).isSymbolicLink();
        if (!isSymlink) continue;
        const isSystem = source.includes("/system/");
        if (isSystem) {
          if (!sudoCached) {
            if (!(await ensureSudo())) { logError("sudo required"); process.exit(1); }
            sudoCached = true;
          }
          Bun.spawnSync(["sudo", "rm", "-rf", target]);
        } else {
          await unlink(target);
        }
        console.log(`  ${colors.red("removed")} ${target}`);
        count++;
      } catch (e) {
        logError(`Failed to remove ${target}: ${e}`);
      }
    }
    logSuccess(`Removed ${count} symlink(s)`);
  },
});
