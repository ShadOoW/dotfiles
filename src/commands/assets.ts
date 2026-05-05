import { defineCommand } from "citty";
import { existsSync } from "fs";
import { ASSETS, type AssetDef, syncAsset } from "../assets/definitions.ts";
import { getLatestRelease } from "../lib/github.ts";
import { getInstalledVersion, readManifest, setInstalledVersion } from "../lib/manifest.ts";
import { colors, logError, logInfo, logSection, logSuccess, logWarn } from "../lib/console.ts";

async function getLatestVersion(asset: AssetDef): Promise<string | null> {
  if (asset.kind === "git") return null; // git assets tracked by commit
  const release = await getLatestRelease(asset.repo);
  return release?.tag_name ?? null;
}

function printAssetsUsage() {
  console.log(`
Usage: dot assets <subcommand>

Subcommands:
  list          Show all assets with installed and latest versions
  sync [name]   Download/update all assets, or a specific one
  info <name>   Show details for a specific asset

Examples:
  dot assets list
  dot assets sync
  dot assets sync JetBrainsMono
  dot assets info catppuccin-gtk
`);
}

export const assetsListCommand = defineCommand({
  meta: { description: "List all assets with installed and latest versions" },
  async run() {
    const manifest = await readManifest();
    console.log(`\n${"Asset".padEnd(22)} ${"Installed".padEnd(16)} ${"Latest".padEnd(16)} Status`);
    console.log("─".repeat(72));

    for (const asset of ASSETS) {
      const installed = manifest.get(asset.name) ?? "-";
      const latest = asset.kind === "release" ? (await getLatestRelease(asset.repo))?.tag_name ?? "?" : "git";
      const installed_dir = asset.installDir;
      const present = existsSync(installed_dir);

      let status: string;
      if (!present) status = colors.red("not installed");
      else if (installed === "-") status = colors.yellow("untracked");
      else if (latest !== "git" && installed !== latest) status = colors.yellow("update available");
      else status = colors.green("up to date");

      console.log(`${asset.name.padEnd(22)} ${installed.padEnd(16)} ${latest.padEnd(16)} ${status}`);
    }
    console.log("");
  },
});

export const assetsSyncCommand = defineCommand({
  meta: { description: "Download/update assets (all or a specific one)" },
  async run({ rawArgs }) {
    const target = rawArgs.find((a) => !a.startsWith("-"));
    const toSync = target ? ASSETS.filter((a) => a.name === target) : ASSETS;

    if (target && toSync.length === 0) {
      logError(`Unknown asset "${target}". Run 'dot assets list' to see available assets.`);
      process.exit(1);
    }

    const manifest = await readManifest();
    let synced = 0;
    let skipped = 0;

    for (const asset of toSync) {
      logSection(asset.name);
      logInfo(asset.description);

      let latestVersion: string | null = null;
      if (asset.kind === "release") {
        const release = await getLatestRelease(asset.repo);
        if (!release) { logWarn(`Could not fetch release info for ${asset.name}`); continue; }
        latestVersion = release.tag_name;
        const installed = manifest.get(asset.name);
        if (installed === latestVersion && existsSync(asset.installDir)) {
          logInfo(`${asset.name} is already up to date (${latestVersion})`);
          skipped++;
          continue;
        }
        logInfo(`Updating ${asset.name}: ${installed ?? "not installed"} → ${latestVersion}`);
      } else {
        logInfo(`Syncing git asset: ${asset.remote}`);
      }

      try {
        await syncAsset(asset, latestVersion ?? "");
        const version = latestVersion ?? "git";
        await setInstalledVersion(asset.name, version);
        logSuccess(`${asset.name} → ${version}`);
        synced++;
      } catch (e) {
        logError(`Failed to sync ${asset.name}: ${e}`);
      }
    }

    console.log(`\nSynced: ${synced}  Skipped (up to date): ${skipped}`);
  },
});

export const assetsInfoCommand = defineCommand({
  meta: { description: "Show details for a specific asset" },
  async run({ rawArgs }) {
    const name = rawArgs[0];
    if (!name) {
      console.log(`\nUsage: dot assets info <name>\n\nAssets: ${ASSETS.map((a) => a.name).join(", ")}\n`);
      process.exit(0);
    }

    const asset = ASSETS.find((a) => a.name === name);
    if (!asset) {
      logError(`Unknown asset "${name}"`);
      process.exit(1);
    }

    const installed = await getInstalledVersion(name);
    console.log(`\n${colors.bold(asset.name)} — ${asset.description}`);
    console.log(`  Kind:      ${asset.kind}`);
    if (asset.kind === "release") console.log(`  Source:    github.com/${asset.repo}`);
    else console.log(`  Source:    ${asset.remote}`);
    console.log(`  Install:   ${asset.installDir}${asset.sudo ? " (requires sudo)" : ""}`);
    console.log(`  Installed: ${installed ?? colors.dim("not tracked")}`);

    if (asset.kind === "release") {
      const release = await getLatestRelease(asset.repo);
      console.log(`  Latest:    ${release?.tag_name ?? colors.dim("unknown")}`);
    }
    console.log("");
  },
});

export const assetsCommand = defineCommand({
  meta: { description: "Manage fonts, icons, themes, and cursors from GitHub releases" },
  subCommands: {
    list: assetsListCommand,
    sync: assetsSyncCommand,
    info: assetsInfoCommand,
  },
  async run() {
    printAssetsUsage();
  },
});
