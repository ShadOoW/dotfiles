import { existsSync } from "fs";
import { mkdir, readFile, writeFile } from "fs/promises";
import { dirname, join } from "path";
import { HOME_DIR } from "./config.ts";

export const MANIFEST_PATH = join(HOME_DIR, ".local/share/assets/versions.json");

export async function readManifest(): Promise<Map<string, string>> {
  if (!existsSync(MANIFEST_PATH)) return new Map();
  const obj = JSON.parse(await readFile(MANIFEST_PATH, "utf-8")) as Record<string, string>;
  return new Map(Object.entries(obj));
}

export async function writeManifest(manifest: Map<string, string>): Promise<void> {
  await mkdir(dirname(MANIFEST_PATH), { recursive: true });
  await writeFile(MANIFEST_PATH, JSON.stringify(Object.fromEntries(manifest), null, 2));
}

export async function getInstalledVersion(name: string): Promise<string | null> {
  return (await readManifest()).get(name) ?? null;
}

export async function setInstalledVersion(name: string, version: string): Promise<void> {
  const manifest = await readManifest();
  manifest.set(name, version);
  await writeManifest(manifest);
}
