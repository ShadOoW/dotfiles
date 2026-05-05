import { join } from "path";
import { HOME_DIR } from "../lib/config.ts";
import { downloadAndExtract, gitCloneOrPull } from "../lib/downloader.ts";
import { getLatestRelease, findAsset } from "../lib/github.ts";
import { logInfo, logWarn, commandExists } from "../lib/console.ts";

export type ReleaseAsset = {
  kind: "release";
  name: string;
  description: string;
  repo: string;
  filePattern: RegExp;
  installDir: string;
  sudo?: boolean;
  postInstall?: () => Promise<void>;
  getVersion?: () => Promise<string | null>;
};

export type GitAsset = {
  kind: "git";
  name: string;
  description: string;
  remote: string;
  installDir: string;
  sudo?: boolean;
};

export type AssetDef = ReleaseAsset | GitAsset;

const fontsDir = join(HOME_DIR, ".local/share/fonts");
const iconsDir = join(HOME_DIR, ".local/share/icons");
const themesDir = join(HOME_DIR, ".local/share/themes");

const refreshFontCache = async () => {
  if (commandExists("fc-cache")) {
    logInfo("Refreshing font cache…");
    Bun.spawnSync(["fc-cache", "-fv"], { stdout: "ignore", stderr: "ignore" });
  }
};

export async function syncAsset(asset: AssetDef, latestVersion: string): Promise<void> {
  if (asset.kind === "git") {
    await gitCloneOrPull(asset.remote, asset.installDir, asset.sudo);
    return;
  }

  const release = await getLatestRelease(asset.repo);
  if (!release) throw new Error(`Could not fetch release for ${asset.repo}`);

  const file = findAsset(release, asset.filePattern);
  if (!file) throw new Error(`No matching asset in ${asset.repo} release ${release.tag_name}`);

  await downloadAndExtract(file.browser_download_url, asset.installDir, asset.sudo);
  if (asset.postInstall) await asset.postInstall();
}

export const ASSETS: AssetDef[] = [
  {
    kind: "release",
    name: "JetBrainsMono",
    description: "JetBrains Mono Nerd Font",
    repo: "ryanoasis/nerd-fonts",
    filePattern: /^JetBrainsMono\.zip$/i,
    installDir: join(fontsDir, "JetBrainsMono"),
    postInstall: refreshFontCache,
  },
  {
    kind: "release",
    name: "NotoSansCJK",
    description: "Noto Serif CJK (Chinese, Japanese, Korean)",
    repo: "notofonts/noto-cjk",
    filePattern: /^01_NotoSerifCJK\.ttc\.zip$/i,
    installDir: join(fontsDir, "NotoSansCJK"),
    postInstall: refreshFontCache,
  },
  {
    kind: "release",
    name: "NotoColorEmoji",
    description: "Noto Color Emoji",
    repo: "googlefonts/noto-emoji",
    filePattern: /^NotoColor-Emoji\.ttf$/i,
    installDir: join(fontsDir, "NotoEmoji"),
    postInstall: refreshFontCache,
  },
  {
    kind: "release",
    name: "NotoArabic",
    description: "Noto Sans Arabic",
    repo: "notofonts/noto-fonts",
    filePattern: /NotoSansArabic.*\.zip$/i,
    installDir: join(fontsDir, "NotoArabic"),
    postInstall: refreshFontCache,
  },
  {
    kind: "release",
    name: "Terminus",
    description: "Terminus bitmap font (also used for TTY via vconsole.conf)",
    repo: "terminus-font/terminus-font",
    filePattern: /^terminus-font-[\d.]+\.tar\.gz$/,
    installDir: join(fontsDir, "Terminus"),
    postInstall: refreshFontCache,
  },
  {
    kind: "release",
    name: "candy-icons",
    description: "Candy icon theme",
    repo: "EliverLara/candy-icons",
    filePattern: /^candy-icons\.zip$/i,
    installDir: join(iconsDir, "candy-icons"),
  },
  {
    kind: "release",
    name: "catppuccin-gtk",
    description: "Catppuccin Macchiato GTK theme (sky variant)",
    repo: "catppuccin/gtk",
    filePattern: /catppuccin-macchiato-sky-standard\+default\.zip$/i,
    installDir: join(themesDir, "catppuccin-macchiato-sky-standard+default"),
  },
  {
    kind: "release",
    name: "Bibata-cursor",
    description: "Bibata Original Classic cursor theme",
    repo: "ful1e5/Bibata_Cursor",
    filePattern: /^Bibata-Original-Classic\.tar\.xz$/i,
    installDir: join(iconsDir, "Bibata-Original-Classic"),
  },
  {
    kind: "release",
    name: "arch-linux-grub",
    description: "Arch Linux GRUB theme",
    repo: "AdisonCavani/distro-grub-themes",
    filePattern: /^arch-linux\.tar$/i,
    installDir: "/boot/grub/themes/arch-linux",
    sudo: true,
  },
  {
    kind: "git",
    name: "grub-theme",
    description: "Custom GRUB theme",
    remote: "git@github.com:ShadOoW/grub-theme.git",
    installDir: "/boot/grub/themes/shad",
    sudo: true,
  },
];
