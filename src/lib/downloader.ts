import { existsSync } from "fs";
import { mkdir, mkdtemp, readdir, rename, rm } from "fs/promises";
import { join, extname } from "path";
import { HOME_DIR } from "./config.ts";
import { logInfo, logError } from "./console.ts";

const CACHE_DIR = join(HOME_DIR, ".cache/assets");

export async function downloadAndExtract(url: string, destDir: string, sudo = false): Promise<void> {
  await mkdir(CACHE_DIR, { recursive: true });
  const tmp = await mkdtemp(join(CACHE_DIR, "dot-asset-"));
  const filename = url.split("/").pop() ?? "asset";
  const archivePath = join(tmp, filename);

  logInfo(`Downloading ${filename}…`);
  const curl = Bun.spawnSync(["curl", "-L", "-o", archivePath, "--silent", "--show-error", url]);
  if (curl.exitCode !== 0) throw new Error(`Download failed: ${new TextDecoder().decode(curl.stderr)}`);

  logInfo("Extracting…");
  const extractDir = join(tmp, "extracted");
  await mkdir(extractDir, { recursive: true });

  const lower = filename.toLowerCase();
  let r;
  if (lower.endsWith(".tar.gz") || lower.endsWith(".tgz")) {
    r = Bun.spawnSync(["tar", "-xzf", archivePath, "-C", extractDir]);
  } else if (lower.endsWith(".tar.xz")) {
    r = Bun.spawnSync(["tar", "-xJf", archivePath, "-C", extractDir]);
  } else if (lower.endsWith(".zip")) {
    r = Bun.spawnSync(["unzip", "-q", archivePath, "-d", extractDir]);
  } else {
    // Single file — just copy it
    await mkdir(destDir, { recursive: true });
    await Bun.write(join(destDir, filename), Bun.file(archivePath));
    await rm(tmp, { recursive: true });
    return;
  }

  if (r.exitCode !== 0) throw new Error(`Extraction failed for ${filename}`);

  // If extraction produced a single subdirectory, use its contents
  const extractedEntries = await readdir(extractDir, { withFileTypes: true });
  let sourceDir = extractDir;
  if (extractedEntries.length === 1 && extractedEntries[0].isDirectory()) {
    sourceDir = join(extractDir, extractedEntries[0].name);
  }

  const mkdirArgs = ["mkdir", "-p", destDir];
  const cpArgs = ["sh", "-c", `cp -r "${sourceDir}/." "${destDir}/"`];

  if (sudo) {
    Bun.spawnSync(["sudo", ...mkdirArgs]);
    const cp = Bun.spawnSync(["sudo", ...cpArgs]);
    if (cp.exitCode !== 0) throw new Error("Copy to dest failed");
  } else {
    await mkdir(destDir, { recursive: true });
    const cp = Bun.spawnSync(cpArgs);
    if (cp.exitCode !== 0) throw new Error("Copy to dest failed");
  }

  await rm(tmp, { recursive: true });
}

export async function gitCloneOrPull(remote: string, destDir: string, sudo = false): Promise<string> {
  const run = (args: string[]) =>
    Bun.spawnSync(sudo ? ["sudo", ...args] : args, { stdout: "pipe", stderr: "pipe" });

  if (existsSync(destDir)) {
    logInfo("Pulling latest changes…");
    const r = run(["git", "-C", destDir, "pull"]);
    if (r.exitCode !== 0) {
      throw new Error(`git pull failed: ${new TextDecoder().decode(r.stderr)}`);
    }
  } else {
    logInfo("Cloning repository…");
    sudo && Bun.spawnSync(["sudo", "mkdir", "-p", destDir]);
    const r = run(["git", "clone", "--depth=1", remote, destDir]);
    if (r.exitCode !== 0) {
      throw new Error(`git clone failed: ${new TextDecoder().decode(r.stderr)}`);
    }
  }

  const rev = Bun.spawnSync(["git", "-C", destDir, "rev-parse", "--short", "HEAD"], { stdout: "pipe" });
  return new TextDecoder().decode(rev.stdout).trim();
}
