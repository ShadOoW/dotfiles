import { existsSync } from "fs";
import { mkdir, readFile, writeFile } from "fs/promises";
import { dirname, join } from "path";
import { HOME_DIR } from "./config.ts";

export const MANIFEST_PATH = join(HOME_DIR, ".local/share/assets/.manifest");

export async function readManifest(): Promise<Map<string, string>> {
  const map = new Map<string, string>();
  if (!existsSync(MANIFEST_PATH)) return map;
  const lines = (await readFile(MANIFEST_PATH, "utf-8")).split("\n");
  for (const line of lines) {
    const [name, version] = line.split("=");
    if (name && version) map.set(name.trim(), version.trim());
  }
  return map;
}

export async function writeManifest(manifest: Map<string, string>): Promise<void> {
  await mkdir(dirname(MANIFEST_PATH), { recursive: true });
  const content = [...manifest.entries()].map(([k, v]) => `${k}=${v}`).join("\n") + "\n";
  await writeFile(MANIFEST_PATH, content);
}

export async function getInstalledVersion(name: string): Promise<string | null> {
  return (await readManifest()).get(name) ?? null;
}

export async function setInstalledVersion(name: string, version: string): Promise<void> {
  const manifest = await readManifest();
  manifest.set(name, version);
  await writeManifest(manifest);
}
