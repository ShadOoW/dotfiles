import { defineCommand } from "citty";
import { existsSync } from "fs";
import { lstatSync, readlinkSync } from "fs";
import { join } from "path";
import { PACKAGES_DIR } from "../lib/config.ts";
import { collectFiles, getPackageMeta, listPackages } from "../lib/pkg.ts";
import { colors, logError, logInfo } from "../lib/console.ts";
import { linkPackage } from "./link.ts";
import { unlinkPackage } from "./link.ts";
import { showPackageInfo, runConfigure, runInitScript } from "./info.ts";

// ─── status helpers ───────────────────────────────────────────────────────────

type FileStatus = "ok" | "broken" | "missing" | "drift";

function checkFileStatus(source: string, target: string): FileStatus {
  if (!existsSync(target)) return "missing";
  try {
    const stat = lstatSync(target);
    if (!stat.isSymbolicLink()) return "drift";
    return readlinkSync(target) === source ? "ok" : "broken";
  } catch {
    return "missing";
  }
}

async function showPackageStatus(pkg: string): Promise<void> {
  const pkgDir = join(PACKAGES_DIR, pkg);
  if (!existsSync(pkgDir)) { logError(`Package "${pkg}" not found`); return; }

  const homeFiles = await collectFiles(pkgDir, "home");
  const systemFiles = await collectFiles(pkgDir, "system");
  const allFiles = [...homeFiles, ...systemFiles];

  if (allFiles.length === 0) {
    console.log(`  ${colors.dim(pkg)}: no files`);
    return;
  }

  const statusIcon: Record<FileStatus, string> = {
    ok:      colors.green("✓"),
    broken:  colors.red("✗"),
    missing: colors.yellow("?"),
    drift:   colors.yellow("~"),
  };
  const statusLabel: Record<FileStatus, string> = {
    ok:      "",
    broken:  "  [broken symlink]",
    missing: "  [missing]",
    drift:   "  [not a symlink — manually modified?]",
  };

  console.log(`\n${colors.bold(pkg)}`);
  let okCount = 0;
  for (const { source, target } of allFiles) {
    const s = checkFileStatus(source, target);
    console.log(`  ${statusIcon[s]} ${target}${colors.dim(statusLabel[s])}`);
    if (s === "ok") okCount++;
  }
  console.log(`  ${colors.dim(`${okCount}/${allFiles.length} linked`)}`);
}

async function showAllStatus(): Promise<void> {
  const pkgs = await listPackages();
  console.log(`\n${"Package".padEnd(22)} ${"Status".padEnd(14)} Files`);
  console.log("─".repeat(52));

  for (const name of pkgs) {
    const pkgDir = join(PACKAGES_DIR, name);
    const homeFiles = await collectFiles(pkgDir, "home");
    const systemFiles = await collectFiles(pkgDir, "system");
    const allFiles = [...homeFiles, ...systemFiles];
    if (allFiles.length === 0) continue;

    const counts: Record<FileStatus, number> = { ok: 0, broken: 0, missing: 0, drift: 0 };
    for (const { source, target } of allFiles) counts[checkFileStatus(source, target)]++;

    const allOk = counts.ok === allFiles.length;
    const noneOk = counts.ok === 0;
    const hasIssues = counts.broken > 0 || counts.drift > 0;

    const rawStatus = allOk ? "ok" : noneOk ? "not linked" : hasIssues ? "issues" : "partial";
    const paddedRaw = rawStatus.padEnd(14);
    const statusStr = allOk    ? colors.green(paddedRaw)
                    : noneOk   ? colors.dim(paddedRaw)
                    : hasIssues ? colors.red(paddedRaw)
                    :             colors.yellow(paddedRaw);

    const issues: string[] = [];
    if (counts.broken > 0) issues.push(`${counts.broken} broken`);
    if (counts.drift > 0) issues.push(`${counts.drift} drift`);
    if (counts.missing > 0 && !noneOk) issues.push(`${counts.missing} missing`);
    const detail = `${counts.ok}/${allFiles.length}` + (issues.length ? ` (${issues.join(", ")})` : "");

    console.log(`  ${name.padEnd(20)} ${statusStr} ${detail}`);
  }
  console.log("");
}

// ─── dispatch ─────────────────────────────────────────────────────────────────

async function dispatch(
  pkg: string,
  action: string,
  args: { init?: string; "dry-run"?: boolean; yes?: boolean }
): Promise<void> {
  switch (action) {
    case "info":      return showPackageInfo(pkg);
    case "link":      return linkPackage(pkg, args.init, args["dry-run"] ?? false);
    case "unlink":    return unlinkPackage(pkg, args.init, args.yes ?? false);
    case "status":    return showPackageStatus(pkg);
    case "configure": return runConfigure(pkg);
    case "enable":    return runInitScript(pkg, "enable", args.init);
    case "disable":   return runInitScript(pkg, "disable", args.init);
    default:
      logError(`Unknown action "${action}". Valid: link, unlink, info, status, configure, enable, disable`);
  }
}

// ─── command ─────────────────────────────────────────────────────────────────

export const pkgCommand = defineCommand({
  meta: { description: "Manage dotfile packages" },
  args: {
    init: { type: "string", description: "Init system: runit or systemd" },
    "dry-run": { type: "boolean", description: "Preview without applying (link only)" },
    yes: { type: "boolean", short: "y", description: "Skip confirmation (unlink only)" },
    tag: { type: "string", description: "Apply action to all packages with this tag" },
  },
  async run({ args, rawArgs }) {
    if (args.tag) {
      // Filter out the tag value from positionals (it's consumed by --tag)
      const positionals = rawArgs.filter((a) => !a.startsWith("-") && a !== args.tag);
      const action = positionals[0] ?? "link";

      const allPkgs = await listPackages();
      const tagged: string[] = [];
      for (const name of allPkgs) {
        const meta = await getPackageMeta(name);
        if (meta?.tags.includes(args.tag!)) tagged.push(name);
      }
      if (tagged.length === 0) {
        logError(`No packages found with tag "${args.tag}"`);
        return;
      }
      logInfo(`Packages tagged "${args.tag}": ${tagged.join(", ")}`);
      for (const name of tagged) await dispatch(name, action, args);
      return;
    }

    const positionals = rawArgs.filter((a) => !a.startsWith("-"));
    const [pkgName, action] = positionals;

    if (!pkgName) {
      const pkgs = await listPackages();
      console.log(`
Usage: dot pkg <package> [action] [flags]
       dot pkg status
       dot pkg --tag <tag> [action]

Actions:
  info        Show package metadata and file list (default)
  link        Symlink config files into place
  unlink      Remove symlinks
  status      Check symlink health
  configure   Run configure.sh
  enable      Enable service
  disable     Disable service

Flags:
  --init runit|systemd   Init system (auto-detected)
  --dry-run              Preview link changes
  -y, --yes              Skip unlink confirmation
  --tag <tag>            Apply action to all packages with this tag

Available packages:
  ${pkgs.join("  ")}
`);
      return;
    }

    if (pkgName === "status" && !action) {
      await showAllStatus();
      return;
    }

    if (!existsSync(join(PACKAGES_DIR, pkgName))) {
      logError(`Package "${pkgName}" not found`);
      return;
    }

    await dispatch(pkgName, action ?? "info", args);
  },
});
