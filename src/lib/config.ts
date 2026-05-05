import { dirname, join } from "path";

// This file lives at <root>/src/lib/config.ts — root is two levels up
export const DOTFILES_DIR = join(dirname(import.meta.path), "../..");
export const PACKAGES_DIR = join(DOTFILES_DIR, "packages");
export const DOCS_DIR = join(DOTFILES_DIR, "docs");
export const HOME_DIR = process.env.HOME ?? "/root";
