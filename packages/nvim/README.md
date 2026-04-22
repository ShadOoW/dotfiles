# nvim - Neovim with LSP and Mason

## System Packages (Void Linux)

```
xbps-install neovim neovim-lua luajit ripgrep fd findutils
xbps-install just stylua shfmt shellcheck prettierd ruff taplo
xbps-install ctags pandoc glow
xbps-install python3 python3-pip
```

## Mason Tools (auto-installed on first run)

LSP servers (configured in `lua/lsp/servers-list.lua`):

- vtsls, astro, eslint, jsonls, yamlls, marksman, bashls
- dockerls, clangd, lua_ls, rust_analyzer, ols, dartls
- superhtml, cssls, biome, basedpyright, ruff

Linters/Formatters (configured in `lua/plugins/lsp/mason-tool-installer.lua`):

- biome, eslint_d, stylelint, htmlhint, alex, shellcheck
- vale, codespell, gitlint, yamllint, jsonlint
- markdownlint, textlint, prettier, prettierd, dprint
- black, isort, ruff, sql-formatter, yamlfix
- tree-sitter-cli, grammarly-languageserver, ltex-ls, odinfmt

## Setup

```bash
mkdir -p /tmp/nvim/{swap,backup,undo}
chmod 700 /tmp/nvim/{swap,backup,undo}
```
