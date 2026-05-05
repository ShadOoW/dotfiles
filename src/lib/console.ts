const noColor = Boolean(process.env.NO_COLOR);

const c = (code: string) => (noColor ? "" : `\x1b[${code}m`);
const reset = c("0");

export const colors = {
  red: (s: string) => `${c("0;31")}${s}${reset}`,
  green: (s: string) => `${c("0;32")}${s}${reset}`,
  yellow: (s: string) => `${c("1;33")}${s}${reset}`,
  blue: (s: string) => `${c("0;34")}${s}${reset}`,
  cyan: (s: string) => `${c("0;36")}${s}${reset}`,
  bold: (s: string) => `${c("1")}${s}${reset}`,
  dim: (s: string) => `${c("2")}${s}${reset}`,
};

export function logInfo(msg: string) {
  console.log(`${colors.green("[INFO]")} ${msg}`);
}
export function logWarn(msg: string) {
  console.log(`${colors.yellow("[WARN]")} ${msg}`);
}
export function logError(msg: string) {
  console.error(`${colors.red("[ERROR]")} ${msg}`);
}
export function logSuccess(msg: string) {
  console.log(`${colors.green("✓")} ${msg}`);
}
export function logSection(msg: string) {
  console.log(`\n${colors.bold(colors.blue(`=== ${msg} ===`))}`);
}

export function formatBytes(bytes: number): string {
  for (const unit of ["B", "KB", "MB", "GB"]) {
    if (Math.abs(bytes) < 1024) return `${bytes.toFixed(1)} ${unit}`;
    bytes /= 1024;
  }
  return `${bytes.toFixed(1)} TB`;
}

export function commandExists(cmd: string): boolean {
  const r = Bun.spawnSync(["which", cmd], { stdout: "ignore", stderr: "ignore" });
  return r.exitCode === 0;
}

export function getVersion(cmd: string, args: string[]): string {
  try {
    const r = Bun.spawnSync([cmd, ...args], { stdout: "pipe", stderr: "pipe" });
    return new TextDecoder().decode(r.stdout).trim();
  } catch {
    return "unknown";
  }
}
