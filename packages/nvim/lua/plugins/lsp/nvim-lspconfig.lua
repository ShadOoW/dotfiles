return { -- Main LSP Configuration
  'neovim/nvim-lspconfig',
  dependencies = {
    'stevearc/conform.nvim',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'j-hui/fidget.nvim',
  },
  config = function()
    -- Initialize LSP setup from lsp/setup.lua
    require('lsp.setup').setup()

    -- LSP servers will be installed by mason-tool-installer
    -- and configured by mason-lspconfig in their respective files
  end,
}
