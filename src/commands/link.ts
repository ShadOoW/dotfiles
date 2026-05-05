import { defineCommand } from "citty";
import { confirm } from "@clack/prompts";
import { existsSync, lstatSync } from "fs";
import { mkdir, rm, symlink } from "fs/promises";
import { dirname, join } from "path";
import { PACKAGES_DIR } from "../lib/config.ts";
import { collectFiles, hasInitDirs, isAlreadyLinked, listPackages } from "../lib/pkg.ts";
import { colors, logError, logInfo, logSuccess, logWarn } from "../lib/console.ts";

function printLinkUsage() {
  console.log(`
Usage: dot link <package> [--init runit|systemd]

Links a package's config files into their target locations.
Home files (~/) are linked without sudo. System files (/) prompt for sudo.

Examples:
  dot link zsh
  dot link udev
  dot link ly --init runit

Run ${colors.cyan("dot link")} without args to see available packages.
`);
}

async function ensureSudo(): Promise<boolean> {
  const r = Bun.spawnSync(["sudo", "-v"], { stdout: "ignore", stderr: "ignore" });
  return r.exitCode === 0;
}

export const linkCommand = defineCommand({
  meta: { description: "Symlink a package's config files into their target locations" },
  args: {
    init: { type: "string", description: "Init system: runit or systemd" },
  },
  async run({ args, rawArgs }) {
    const pkg = rawArgs.find((a) => !a.startsWith("-"));
    if (!pkg) {
      const pkgs = await listPackages();
      printLinkUsage();
      console.log(`Available packages:\n  ${pkgs.join("  ")}\n`);
      process.exit(0);
    }

    const pkgDir = join(PACKAGES_DIR, pkg);
    if (!existsSync(pkgDir)) {
      logError(`Package "${pkg}" not found in packages/`);
      process.exit(1);
    }

    const hasHome = existsSync(join(pkgDir, "home"));
    const hasSystem = existsSync(join(pkgDir, "system"));

    if (!hasHome && !hasSystem) {
      logWarn(`Package "${pkg}" has no home/ or system/ directory — nothing to link`);
      return;
    }

    // Validate --init requirement for init-specific system configs
    if (hasSystem) {
      const { runit, systemd } = hasInitDirs(pkgDir);
      if ((runit || systemd) && !args.init) {
        logError(`Package "${pkg}" has init-system-specific configs. Specify --init:`);
        if (runit) console.error(`  dot link ${pkg} --init runit`);
        if (systemd) console.error(`  dot link ${pkg} --init systemd`);
        process.exit(1);
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
        logSuccess(`Linked ${count} home file(s)`);
      }
    }

    if (hasSystem) {
      const files = await collectFiles(pkgDir, "system", args.init);
      if (files.length > 0) {
        if (!sudoCached) {
          if (!(await ensureSudo())) {
            logError("sudo required for system files");
            process.exit(1);
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
        logSuccess(`Linked ${count} system file(s)`);
      }
    }
  },
});

export const unlinkCommand = defineCommand({
  meta: { description: "Remove symlinks created by dot link" },
  args: {
    init: { type: "string", description: "Init system: runit or systemd" },
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

    const hasHome = existsSync(join(pkgDir, "home"));
    const hasSystem = existsSync(join(pkgDir, "system"));
    const homeFiles = hasHome ? await collectFiles(pkgDir, "home") : [];
    const systemFiles = hasSystem ? await collectFiles(pkgDir, "system", args.init) : [];
    const allFiles = [...homeFiles, ...systemFiles];

    if (allFiles.length === 0) {
      logWarn(`No files to unlink for "${pkg}"`);
      return;
    }

    console.log(`\nWill remove ${allFiles.length} symlink(s) for ${colors.bold(pkg)}:`);
    for (const { target } of allFiles) {
      if (existsSync(target)) console.log(`  ${colors.red("✗")} ${target}`);
    }

    const answer = await confirm({ message: "Proceed?" });
    if (!answer) { console.log("Cancelled."); return; }

    let sudoCached = false;
    let count = 0;

    for (const { source, target } of allFiles) {
      if (!existsSync(target)) continue;
      try {
        const isSystem = source.includes("/system/");
        if (isSystem) {
          if (!sudoCached) {
            if (!(await ensureSudo())) { logError("sudo required"); process.exit(1); }
            sudoCached = true;
          }
          Bun.spawnSync(["sudo", "rm", "-rf", target]);
        } else {
          await rm(target, { recursive: true });
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
