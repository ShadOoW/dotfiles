-- LSP servers configuration
return {
    'neovim/nvim-lspconfig',
    dependencies = {'hrsh7th/cmp-nvim-lsp', 'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim'},
    event = {'BufReadPre', 'BufNewFile'},
    config = function()
        -- Configure LSP servers
        local lspconfig = require('lspconfig')
        local handlers = require('lsp.handlers')

        -- Common LSP settings
        local common_settings = {
            capabilities = require('cmp_nvim_lsp').default_capabilities(),
            on_attach = handlers.on_attach
        }

        -- Helper function to load server-specific configuration
        local function load_server_config(server_name)
            local ok, server_config = pcall(require, 'lsp.servers.' .. server_name)
            if ok and server_config then
                return vim.tbl_deep_extend('force', common_settings, server_config)
            end
            return common_settings
        end

        -- Configure individual LSP servers with their specific configurations

        -- HTML/Template files: superhtml (structure), tailwindcss (classes)
        -- CSS files: cssls (pure CSS/SCSS/Less)
        lspconfig.superhtml.setup(load_server_config('superhtml'))
        lspconfig.cssls.setup(load_server_config('cssls'))
        lspconfig.tailwindcss.setup(load_server_config('tailwindcss'))

        -- JavaScript/TypeScript: vtsls only (modern replacement for ts_ls)
        lspconfig.vtsls.setup(load_server_config('vtsls'))

        -- Other web development servers
        lspconfig.eslint.setup(load_server_config('eslint'))
        lspconfig.astro.setup(load_server_config('astro'))

        lspconfig.biome.setup(load_server_config('biome'))

        -- General purpose servers
        lspconfig.jsonls.setup(load_server_config('jsonls'))
        lspconfig.yamlls.setup(load_server_config('yamlls'))
        lspconfig.marksman.setup(load_server_config('marksman'))
        lspconfig.bashls.setup(load_server_config('bashls'))
        lspconfig.dockerls.setup(load_server_config('dockerls'))
        lspconfig.denols.setup(load_server_config('denols'))
        lspconfig.clangd.setup(load_server_config('clangd'))
        lspconfig.lua_ls.setup(load_server_config('lua_ls'))
    end
}
