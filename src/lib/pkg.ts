import { readdir, readFile } from "fs/promises";
import { existsSync, lstatSync, readlinkSync } from "fs";
import { join, dirname } from "path";
import { PACKAGES_DIR, HOME_DIR } from "./config.ts";

export type FileEntry = { source: string; target: string };

export interface PackageMeta {
  name: string;
  description: string;
  requiredPackages: string[];
  configure: boolean;
  enableScripts: { name: string; init?: string }[];
  cleanSteps: string[];
}

export async function listPackages(): Promise<string[]> {
  const entries = await readdir(PACKAGES_DIR, { withFileTypes: true });
  return entries.filter((e) => e.isDirectory()).map((e) => e.name).sort();
}

export async function getPackageMeta(name: string): Promise<PackageMeta | null> {
  const pkgDir = join(PACKAGES_DIR, name);
  if (!existsSync(pkgDir)) return null;

  const readmePath = join(pkgDir, "README.md");
  const readme = existsSync(readmePath) ? await readFile(readmePath, "utf-8") : "";

  return {
    name,
    description: extractDescription(readme),
    requiredPackages: extractRequiredPackages(readme),
    configure: existsSync(join(pkgDir, "configure.sh")),
    enableScripts: collectEnableScripts(pkgDir),
    cleanSteps: extractCleanSteps(readme),
  };
}

export async function collectFiles(pkgDir: string, section: "home" | "system", init?: string): Promise<FileEntry[]> {
  const files: FileEntry[] = [];
  const sectionDir = join(pkgDir, section);
  if (!existsSync(sectionDir)) return files;

  const skipNames = new Set(["README.md", "configure.sh", "CHEATSHEET.md", "setup.sh"]);

  async function walk(dir: string) {
    const entries = await readdir(dir, { withFileTypes: true });
    for (const entry of entries) {
      if (skipNames.has(entry.name) || entry.name.startsWith("enable") || entry.name.startsWith("disable")) continue;
      const full = join(dir, entry.name);
      if (entry.isDirectory()) {
        // Skip init-specific dirs that don't match
        const rel = full.replace(pkgDir + "/", "");
        if (rel === "system/runit" && init !== "runit") continue;
        if (rel === "system/systemd" && init !== "systemd") continue;
        await walk(full);
      } else {
        const relative = full.replace(pkgDir + "/", "");
        files.push({ source: full, target: resolveTarget(relative) });
      }
    }
  }

  await walk(sectionDir);
  return files;
}

export function resolveTarget(relative: string): string {
  if (relative.startsWith("home/")) return join(HOME_DIR, relative.slice(5));
  if (relative.startsWith("system/base/")) return "/" + relative.slice(12);
  if (relative.startsWith("system/runit/")) return "/" + relative.slice(13);
  if (relative.startsWith("system/systemd/")) return "/" + relative.slice(15);
  if (relative.startsWith("system/")) return "/" + relative.slice(7);
  return "/" + relative;
}

export function hasInitDirs(pkgDir: string): { runit: boolean; systemd: boolean } {
  return {
    runit: existsSync(join(pkgDir, "system", "runit")),
    systemd: existsSync(join(pkgDir, "system", "systemd")),
  };
}

export function isAlreadyLinked(source: string, target: string): boolean {
  try {
    if (!existsSync(target)) return false;
    const stat = lstatSync(target);
    return stat.isSymbolicLink() && readlinkSync(target) === source;
  } catch {
    return false;
  }
}

function extractDescription(readme: string): string {
  const m = readme.match(/^# \w+ - (.+)/m);
  return m ? m[1] : "";
}

function extractRequiredPackages(readme: string): string[] {
  const matches = readme.matchAll(/xbps-install (\S+)|apt install (\S+)|pacman -S (\S+)|brew install (\S+)/g);
  const pkgs = new Set<string>();
  for (const m of matches) pkgs.add(m[1] ?? m[2] ?? m[3] ?? m[4]);
  const lines = readme.split("\n");
  let inSoftwareSection = false;
  for (const l of lines) {
    if (l.startsWith("## ")) inSoftwareSection = false;
    if (l.startsWith("## ") && /(?:Software|Required packages)/.test(l)) inSoftwareSection = true;
    else if (inSoftwareSection && l.trim().startsWith("- ")) pkgs.add(l.trim().slice(2).trim());
  }
  return [...pkgs];
}

function collectEnableScripts(pkgDir: string): { name: string; init?: string }[] {
  return ["enable-runit.sh", "enable-systemd.sh", "enable.sh"]
    .filter((f) => existsSync(join(pkgDir, f)))
    .map((f) => ({
      name: f.replace(".sh", ""),
      init: f.includes("runit") ? "runit" : f.includes("systemd") ? "systemd" : undefined,
    }));
}

function extractCleanSteps(readme: string): string[] {
  const m = readme.match(/## Clean[\s\S]*$/m);
  if (!m) return [];
  return m[0].split("\n").filter((l) => l.startsWith("- ")).map((l) => l.slice(2));
}
