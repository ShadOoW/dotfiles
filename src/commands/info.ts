import { defineCommand } from "citty";
import { existsSync } from "fs";
import { join } from "path";
import { PACKAGES_DIR } from "../lib/config.ts";
import { collectFiles, detectDistro, getPackageMeta, listPackages } from "../lib/pkg.ts";
import { colors, logError } from "../lib/console.ts";

export const infoCommand = defineCommand({
  meta: { description: "Show package files and metadata" },
  async run({ rawArgs }) {
    const pkg = rawArgs[0];
    if (!pkg) {
      const pkgs = await listPackages();
      console.log(`\nUsage: dot info <package>\n\nPackages:\n  ${pkgs.join("  ")}\n`);
      process.exit(0);
    }

    const pkgDir = join(PACKAGES_DIR, pkg);
    if (!existsSync(pkgDir)) {
      logError(`Package "${pkg}" not found`);
      process.exit(1);
    }

    const meta = await getPackageMeta(pkg);
    if (!meta) { logError(`Could not read package info for "${pkg}"`); process.exit(1); }

    console.log(`\n${colors.bold(pkg)}${meta.description ? ` — ${meta.description}` : ""}\n`);

    if (meta.tags.length > 0) {
      console.log(`${colors.dim("Tags:")}     ${meta.tags.join(", ")}`);
    }
    if (meta.os.length > 0) {
      console.log(`${colors.dim("OS:")}       ${meta.os.join(", ")}`);
    }
    if (meta.tags.length > 0 || meta.os.length > 0) console.log("");

    const distro = detectDistro();
    const distroPackages = meta.packages[distro] ?? meta.packages["linux"];
    const allDistros = Object.keys(meta.packages);

    if (distroPackages) {
      console.log(colors.yellow(`Packages (${distro}):`));
      for (const [pm, pkgs] of Object.entries(distroPackages)) {
        if (pkgs.length === 0) continue;
        console.log(`  ${colors.cyan(pm + ":")} ${pkgs.join("  ")}`);
      }
      console.log("");
    } else if (allDistros.length > 0) {
      for (const [d, pkgList] of Object.entries(meta.packages)) {
        console.log(colors.yellow(`Packages (${d}):`));
        for (const [pm, pkgs] of Object.entries(pkgList)) {
          if (pkgs.length === 0) continue;
          console.log(`  ${colors.cyan(pm + ":")} ${pkgs.join("  ")}`);
        }
      }
      console.log("");
    }

    console.log(colors.cyan("Operations:"));
    console.log(`  dot link ${pkg}`);
    console.log(`  dot unlink ${pkg}`);
    if (meta.configure) console.log(`  dot configure ${pkg}`);
    for (const s of meta.enableScripts) {
      const hint = s.init ? ` --init ${s.init}` : "";
      console.log(`  dot enable ${pkg}${hint}`);
    }
    console.log("");

    const homeFiles = await collectFiles(pkgDir, "home");
    const systemFiles = await collectFiles(pkgDir, "system");
    const allFiles = [...homeFiles, ...systemFiles];

    if (allFiles.length > 0) {
      console.log(colors.cyan("Files:"));
      for (const { source, target } of allFiles) {
        const rel = source.replace(pkgDir + "/", "");
        console.log(`  ${colors.dim(rel)} → ${target}`);
      }
      console.log("");
    }

    if (meta.cleanSteps.length > 0) {
      console.log(colors.yellow("Clean steps:"));
      for (const step of meta.cleanSteps) console.log(`  ${step}`);
      console.log("");
    }
  },
});

export const configureCommand = defineCommand({
  meta: { description: "Run a package's configure.sh script" },
  async run({ rawArgs }) {
    const pkg = rawArgs[0];
    if (!pkg) {
      console.log("\nUsage: dot configure <package>\n");
      process.exit(0);
    }

    const scriptPath = join(PACKAGES_DIR, pkg, "configure.sh");
    if (!existsSync(scriptPath)) {
      logError(`No configure.sh found for "${pkg}"`);
      process.exit(1);
    }

    const r = Bun.spawnSync(["sudo", "-v"], { stdout: "ignore", stderr: "ignore" });
    if (r.exitCode !== 0) { logError("sudo required"); process.exit(1); }

  const proc = Bun.spawn(["bash", scriptPath], { stdout: "inherit", stderr: "inherit" });
    process.exit(await proc.exited);
  },
});

export const enableCommand = defineCommand({
  meta: { description: "Run a package's enable script" },
  args: {
    init: { type: "string", description: "Init system: runit or systemd" },
  },
  async run({ args, rawArgs }) {
    const pkg = rawArgs.find((a) => !a.startsWith("-"));
    if (!pkg) { console.log("\nUsage: dot enable <package> [--init runit|systemd]\n"); process.exit(0); }
    await runInitScript(pkg, "enable", args.init);
  },
});

export const disableCommand = defineCommand({
  meta: { description: "Run a package's disable script" },
  args: {
    init: { type: "string", description: "Init system: runit or systemd" },
  },
  async run({ args, rawArgs }) {
    const pkg = rawArgs.find((a) => !a.startsWith("-"));
    if (!pkg) { console.log("\nUsage: dot disable <package> [--init runit|systemd]\n"); process.exit(0); }
    await runInitScript(pkg, "disable", args.init);
  },
});

async function runInitScript(pkg: string, action: "enable" | "disable", init?: string) {
  const meta = await getPackageMeta(pkg);
  if (!meta) { logError(`Package "${pkg}" not found`); process.exit(1); }

  const scripts = meta.enableScripts;
  if (scripts.length === 0) {
    logError(`No ${action} script for "${pkg}"`);
    process.exit(1);
  }

  let scriptName: string;
  if (scripts.length === 1) {
    scriptName = scripts[0].name;
  } else {
    if (!init) {
      logError(`Multiple init systems available. Specify --init:`);
      for (const s of scripts) console.error(`  dot ${action} ${pkg} --init ${s.init}`);
      process.exit(1);
    }
    const found = scripts.find((s) => s.init === init);
    if (!found) {
      logError(`Unknown init system "${init}". Available: ${scripts.map((s) => s.init).join(", ")}`);
      process.exit(1);
    }
    scriptName = found.name;
  }

  const baseName = action === "disable" ? scriptName.replace("enable-", "disable-") : scriptName;
  const scriptPath = join(PACKAGES_DIR, pkg, `${baseName}.sh`);
  if (!existsSync(scriptPath)) {
    logError(`Script not found: ${scriptPath}`);
    process.exit(1);
  }

  const proc = Bun.spawn(["sudo", "bash", scriptPath], { stdout: "inherit", stderr: "inherit" });
  process.exit(await proc.exited);
}
