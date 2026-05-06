import { join } from "path";
import { HOME_DIR } from "../lib/config.ts";
import { downloadAndExtract, gitCloneOrPull, gitInstallerSync } from "../lib/downloader.ts";
import { getLatestRelease, findAsset } from "../lib/github.ts";
import { logInfo, commandExists } from "../lib/console.ts";

export type ReleaseAsset = {
  kind: "release";
  name: string;
  description: string;
  repo: string;
  filePattern: RegExp;
  installDir: string;
  sudo?: boolean;
  postInstall?: () => Promise<void>;
};

export type ReleaseTarballAsset = {
  kind: "release-tarball";
  name: string;
  description: string;
  repo: string;
  installDir: string;
  sudo?: boolean;
  postInstall?: () => Promise<void>;
};

export type GitInstallerAsset = {
  kind: "git-installer";
  name: string;
  description: string;
  remote: string;
  installDir: string;
  installCmd: string[];
  sudo?: boolean;
  postInstall?: () => Promise<void>;
};

export type UrlAsset = {
  kind: "url";
  name: string;
  description: string;
  downloadUrl: string;
  version: string;
  installDir: string;
  sudo?: boolean;
  postInstall?: () => Promise<void>;
};

export type GitAsset = {
  kind: "git";
  name: string;
  description: string;
  remote: string;
  installDir: string;
  sudo?: boolean;
};

export type AssetDef =
  | ReleaseAsset
  | ReleaseTarballAsset
  | GitInstallerAsset
  | UrlAsset
  | GitAsset;

const fontsDir = join(HOME_DIR, ".local/share/fonts");
const iconsDir = join(HOME_DIR, ".local/share/icons");
const themesDir = join(HOME_DIR, ".local/share/themes");
const binDir = join(HOME_DIR, ".local/bin");

const refreshFontCache = async () => {
  if (commandExists("fc-cache")) {
    logInfo("Refreshing font cache…");
    Bun.spawnSync(["fc-cache", "-fv"], { stdout: "ignore", stderr: "ignore" });
  }
};

const makeExecutable = async (file: string) => {
  logInfo(`Making executable: ${file}`);
  Bun.spawnSync(["chmod", "+x", file]);
};

export async function syncAsset(asset: AssetDef, latestVersion: string): Promise<void> {
  if (asset.kind === "git-installer") {
    await gitInstallerSync(asset.remote, asset.installDir, asset.installCmd, asset.sudo);
    if (asset.postInstall) await asset.postInstall();
    return;
  }

  if (asset.kind === "git") {
    await gitCloneOrPull(asset.remote, asset.installDir, asset.sudo);
    return;
  }

  if (asset.kind === "url") {
    await downloadAndExtract(asset.downloadUrl, asset.installDir, asset.sudo);
    if (asset.postInstall) await asset.postInstall();
    return;
  }

  const release = await getLatestRelease(asset.repo);
  if (!release) throw new Error(`Could not fetch release for ${asset.repo}`);

  if (asset.kind === "release") {
    const file = findAsset(release, asset.filePattern);
    if (!file) throw new Error(`No matching asset in ${asset.repo} release ${release.tag_name}`);
    await downloadAndExtract(file.browser_download_url, asset.installDir, asset.sudo);
  } else if (asset.kind === "release-tarball") {
    await downloadAndExtract(release.tarball_url, asset.installDir, asset.sudo, 1);
  }

  if (asset.postInstall) await asset.postInstall();
}

export const ASSETS: AssetDef[] = [
  {
    kind: "release",
    name: "JetBrainsMono",
    description: "JetBrains Mono Nerd Font",
    repo: "ryanoasis/nerd-fonts",
    filePattern: /^JetBrainsMono\.tar\.xz$/i,
    installDir: join(fontsDir, "JetBrainsMono"),
    postInstall: refreshFontCache,
  },
  {
    kind: "release",
    name: "Terminus",
    description: "Terminus Nerd Font (bitmap terminal font)",
    repo: "ryanoasis/nerd-fonts",
    filePattern: /^Terminus\.tar\.xz$/i,
    installDir: join(fontsDir, "Terminus"),
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
    kind: "release-tarball",
    name: "Papirus",
    description: "Papirus icon theme",
    repo: "PapirusDevelopmentTeam/papirus-icon-theme",
    installDir: iconsDir,
  },
  {
    kind: "release-tarball",
    name: "papirus-folders",
    description: "Papirus folder color tool",
    repo: "PapirusDevelopmentTeam/papirus-folders",
    installDir: binDir,
    postInstall: async () => makeExecutable(join(binDir, "papirus-folders")),
  },
  {
    kind: "git-installer",
    name: "Tokyonight-GTK",
    description: "Tokyonight GTK theme (dark, blue accent)",
    remote: "https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme.git",
    installDir: join(HOME_DIR, ".local/share/tokyonight-gtk"),
    installCmd: [
      "git submodule update --init --recursive",
      "cd themes && ./install.sh --color dark --theme default --dest ~/.local/share/themes",
    ],
  },
  {
    kind: "release",
    name: "Bibata-cursor",
    description: "Bibata Modern Classic cursor theme",
    repo: "ful1e5/Bibata_Cursor",
    filePattern: /^Bibata-Modern-Classic\.tar\.xz$/i,
    installDir: join(iconsDir, "Bibata-Modern-Classic"),
  },
];
