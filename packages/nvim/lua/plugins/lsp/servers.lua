-- LSP servers configuration
return {
  'neovim/nvim-lspconfig',
  dependencies = { 'hrsh7th/cmp-nvim-lsp', 'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim' },
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    -- Configure LSP servers
    local lspconfig = require('lspconfig')
    local handlers = require('lsp.handlers')

    -- Configure diagnostics first
    handlers.setup_diagnostics()

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

    -- HTML/Template files: superhtml (structure), tailwindcss (classes)
    -- Enhanced HTML configuration to ensure consistent attachment
    local html_config = load_server_config('superhtml')
    html_config.autostart = true
    html_config.single_file_support = true
    lspconfig.superhtml.setup(html_config)

    -- CSS files: cssls (pure CSS/SCSS/Less)
    lspconfig.cssls.setup(load_server_config('cssls'))

    -- TailwindCSS for HTML and other web files
    local tailwind_config = load_server_config('tailwindcss')
    tailwind_config.autostart = true
    lspconfig.tailwindcss.setup(tailwind_config)

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

    -- Force HTML filetype detection for consistency
    vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
      pattern = { '*.html', '*.htm', '*.xhtml' },
      callback = function(args)
        vim.bo[args.buf].filetype = 'html'
        -- Ensure treesitter parser is available
        vim.schedule(function() vim.cmd('TSBufEnable highlight') end)
      end,
      desc = 'Force HTML filetype detection for consistent LSP/treesitter behavior',
    })
  end,
}
