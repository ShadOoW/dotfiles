-- LSP servers configuration
return {
  'neovim/nvim-lspconfig',
  dependencies = { 'hrsh7th/cmp-nvim-lsp', 'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim' },
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    -- Configure LSP servers
    local lspconfig = require('lspconfig')
    local handlers = require('lsp.handlers')

    -- Common LSP settings
    local common_settings = {
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      on_attach = handlers.on_attach,
    }

    -- Helper function to load server-specific configuration
    local function load_server_config(server_name)
      local ok, server_config = pcall(require, 'lsp.servers.' .. server_name)
      if ok and server_config then return vim.tbl_deep_extend('force', common_settings, server_config) end
      return common_settings
    end

    -- Configure individual LSP servers with their specific configurations
    lspconfig.html.setup(load_server_config('html'))
    lspconfig.cssls.setup(load_server_config('cssls'))
    lspconfig.ts_ls.setup(load_server_config('ts_ls'))
    lspconfig.eslint.setup(load_server_config('eslint'))
    lspconfig.tailwindcss.setup(load_server_config('tailwindcss'))
    lspconfig.astro.setup(load_server_config('astro'))
    lspconfig.emmet_ls.setup(load_server_config('emmet_ls'))
    lspconfig.jsonls.setup(load_server_config('jsonls'))
    lspconfig.yamlls.setup(load_server_config('yamlls'))
    lspconfig.marksman.setup(load_server_config('marksman'))
    lspconfig.bashls.setup(load_server_config('bashls'))
    lspconfig.dockerls.setup(load_server_config('dockerls'))
    lspconfig.denols.setup(load_server_config('denols'))
    lspconfig.clangd.setup(load_server_config('clangd'))
    lspconfig.lua_ls.setup(load_server_config('lua_ls'))
  end,
}
