import { defineCommand } from "citty";
import { existsSync } from "fs";
import { readdir, readFile } from "fs/promises";
import { join, basename } from "path";
import { DOCS_DIR } from "../lib/config.ts";
import { colors, commandExists, logError } from "../lib/console.ts";

async function listTopics(): Promise<string[]> {
  if (!existsSync(DOCS_DIR)) return [];
  const entries = await readdir(DOCS_DIR, { withFileTypes: true });
  return entries.filter((e) => e.isFile() && e.name.endsWith(".md")).map((e) => basename(e.name, ".md")).sort();
}

async function showTopic(topic: string) {
  const path = join(DOCS_DIR, `${topic}.md`);
  if (!existsSync(path)) {
    logError(`No documentation for "${topic}"`);
    const topics = await listTopics();
    console.log(`Available topics: ${topics.join(", ")}`);
    process.exit(1);
  }

  if (commandExists("glow")) {
    const proc = Bun.spawn(["glow", path], { stdout: "inherit", stderr: "inherit" });
    await proc.exited;
  } else if (commandExists("less")) {
    const proc = Bun.spawn(["less", path], { stdout: "inherit", stderr: "inherit", stdin: "inherit" });
    await proc.exited;
  } else {
    console.log(await readFile(path, "utf-8"));
  }
}

export const docsCommand = defineCommand({
  meta: { description: "View setup documentation" },
  async run({ rawArgs }) {
    const topic = rawArgs[0];
    if (!topic) {
      const topics = await listTopics();
      if (topics.length === 0) {
        console.log("\nNo documentation found in docs/\n");
        return;
      }
      console.log(`\n${colors.bold("Setup Documentation")}\n`);
      for (const t of topics) {
        console.log(`  ${colors.cyan(t.padEnd(16))} dot docs ${t}`);
      }
      console.log("\nTip: install 'glow' for rendered markdown output\n");
      return;
    }
    await showTopic(topic);
  },
});
