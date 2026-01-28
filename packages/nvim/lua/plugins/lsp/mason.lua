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
      ensure_installed = { -- Web Development
        'cssls', -- CSS
        'eslint', -- ESLint
        'tailwindcss', -- Tailwind CSS
        'astro', -- Astro
        'jsonls', -- JSON
        'yamlls', -- YAML
        -- C/C++ Development
        'clangd', -- C/C++/Objective-C
        -- Systems Programming
        'rust_analyzer', -- Rust Language Server
        'ols', -- Odin Language Server
        -- General
        'lua_ls', -- Lua
        'marksman', -- Markdown
        'bashls', -- Bash
        'dockerls', -- Docker
      },
      automatic_installation = true,
      -- Don't auto-setup servers - we configure them manually in servers.lua
      handlers = {},
    })
  end,
}
