import { confirm } from "@clack/prompts";
import { existsSync, lstatSync, readlinkSync } from "fs";
import { mkdir, rm, symlink, unlink } from "fs/promises";
import { dirname, join } from "path";
import { PACKAGES_DIR } from "../lib/config.ts";
import {
  collectFiles,
  detectInit,
  hasInitDirs,
  isAlreadyLinked,
} from "../lib/pkg.ts";
import { colors, logError, logInfo, logSuccess, logWarn } from "../lib/console.ts";

async function ensureSudo(): Promise<boolean> {
  const r = Bun.spawnSync(["sudo", "-v"], { stdout: "ignore", stderr: "ignore" });
  return r.exitCode === 0;
}

export async function linkPackage(pkg: string, initOverride?: string, dryRun = false): Promise<void> {
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
        if (runit) console.error(`  dot pkg ${pkg} link --init runit`);
        if (systemd) console.error(`  dot pkg ${pkg} link --init systemd`);
        return;
      }
    }
  }

  let sudoCached = false;

  if (hasHome) {
    const files = await collectFiles(pkgDir, "home");
    if (files.length > 0) {
      logInfo(`Linking home files for ${colors.bold(pkg)}…`);
      let newLinks = 0;
      let alreadyCount = 0;
      for (const { source, target } of files) {
        if (isAlreadyLinked(source, target)) {
          console.log(`  ${colors.dim("✓")} ${colors.dim(target)}`);
          alreadyCount++;
          continue;
        }
        if (dryRun) {
          console.log(`  ${colors.cyan("would →")} ${target}`);
          newLinks++;
          continue;
        }
        try {
          await mkdir(dirname(target), { recursive: true });
          if (existsSync(target)) await rm(target, { recursive: true });
          await symlink(source, target);
          console.log(`  ${colors.green("→")} ${target}`);
          newLinks++;
        } catch (e) {
          logError(`  Failed to link ${target}: ${e}`);
        }
      }
      if (dryRun) {
        logInfo(`Would link ${newLinks} home file(s)`);
      } else if (newLinks === 0 && alreadyCount > 0) {
        logSuccess(`All ${alreadyCount} home file(s) already in place`);
      } else if (newLinks > 0) {
        const extra = alreadyCount > 0 ? `, ${alreadyCount} already` : "";
        logSuccess(`Linked ${newLinks} new home file(s)${extra}`);
      }
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
      let newLinks = 0;
      let alreadyCount = 0;
      for (const { source, target } of files) {
        if (isAlreadyLinked(source, target)) {
          console.log(`  ${colors.dim("✓")} ${colors.dim(target)}`);
          alreadyCount++;
          continue;
        }
        if (dryRun) {
          console.log(`  ${colors.cyan("would →")} ${target}`);
          newLinks++;
          continue;
        }
        try {
          Bun.spawnSync(["sudo", "mkdir", "-p", dirname(target)]);
          Bun.spawnSync(["sudo", "rm", "-rf", target]);
          Bun.spawnSync(["sudo", "ln", "-sf", source, target]);
          console.log(`  ${colors.green("→")} ${target}`);
          newLinks++;
        } catch (e) {
          logError(`  Failed to link ${target}: ${e}`);
        }
      }
      if (dryRun) {
        logInfo(`Would link ${newLinks} system file(s)`);
      } else if (newLinks === 0 && alreadyCount > 0) {
        logSuccess(`All ${alreadyCount} system file(s) already in place`);
      } else if (newLinks > 0) {
        const extra = alreadyCount > 0 ? `, ${alreadyCount} already` : "";
        logSuccess(`Linked ${newLinks} new system file(s)${extra}`);
      }
    }
  }
}

export async function unlinkPackage(pkg: string, initOverride?: string, skipConfirm = false): Promise<void> {
  const pkgDir = join(PACKAGES_DIR, pkg);
  if (!existsSync(pkgDir)) {
    logError(`Package "${pkg}" not found`);
    process.exit(1);
  }

  let resolvedInit = initOverride;
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

  const answer = skipConfirm || await confirm({ message: "Proceed?" });
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
}

