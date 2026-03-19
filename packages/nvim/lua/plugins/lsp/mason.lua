-- Mason for LSP and Linter installation
return {
  'williamboman/mason.nvim',
  dependencies = { 'williamboman/mason-lspconfig.nvim', 'neovim/nvim-lspconfig' },
  config = function()
    require('mason').setup({
      ui = {
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗',
        },
      },
    })

    -- Configure Mason LSP
    require('mason-lspconfig').setup({
      -- Derived from lsp/servers-list.lua — the single source of truth.
      -- mason-lspconfig silently skips any names it doesn't manage (e.g. superhtml, dartls).
      ensure_installed = require('lsp.servers-list').mason_servers,
      automatic_installation = true,
      -- Disable automatic_enable: we call vim.lsp.enable() explicitly in servers.lua.
      -- Without this, mason-lspconfig re-enables every installed package (including
      -- orphaned ones like tailwindcss) on every session start.
      automatic_enable = false,
      -- No handlers: servers are configured manually in servers.lua via vim.lsp.config.
      handlers = {},
    })
  end,
}
