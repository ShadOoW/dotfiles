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
        'denols', -- Deno
        -- C/C++ Development
        'clangd', -- C/C++/Objective-C
        -- General
        'lua_ls', -- Lua
        'marksman', -- Markdown
        'bashls', -- Bash
        'dockerls', -- Docker
      },
      automatic_installation = true,
    })
  end,
}
