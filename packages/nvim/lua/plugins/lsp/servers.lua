-- LSP servers configuration
return {
  'neovim/nvim-lspconfig',
  dependencies = { 'hrsh7th/cmp-nvim-lsp', 'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim' },
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    -- Configure LSP servers using vim.lsp.config (new API)
    -- Load lspconfig to register server configurations, but use vim.lsp.config for setup
    require('lspconfig')
    local handlers = require('lsp.handlers')

    -- Configure diagnostics first
    handlers.setup_diagnostics()

    -- Common LSP settings
    local common_settings = {
      -- Use nvim-cmp LSP capabilities for simple, robust completion
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      on_attach = handlers.on_attach,
    }

    -- Helper function to load server-specific configuration
    local function load_server_config(server_name)
      local ok, server_config = pcall(require, 'lsp.servers.' .. server_name)
      if ok and server_config and type(server_config) == 'table' then
        return vim.tbl_deep_extend('force', common_settings, server_config)
      end
      return common_settings
    end

    -- HTML/Template files: superhtml (structure), tailwindcss (classes)
    -- Enhanced HTML configuration to ensure consistent attachment
    local html_config = load_server_config('superhtml')
    html_config.autostart = true
    html_config.single_file_support = true
    vim.lsp.config('superhtml', html_config)

    -- CSS files: cssls (pure CSS/SCSS/Less)
    vim.lsp.config('cssls', load_server_config('cssls'))

    -- TailwindCSS for HTML and other web files
    local tailwind_config = load_server_config('tailwindcss')
    tailwind_config.autostart = true
    vim.lsp.config('tailwindcss', tailwind_config)

    -- JavaScript/TypeScript: vtsls (primary LSP for JS/TS)
    local vtsls_config = load_server_config('vtsls')
    vtsls_config.autostart = true
    vtsls_config.priority = 100
    vim.lsp.config('vtsls', vtsls_config)

    -- ESLint: Only start when config is found
    local eslint_config = load_server_config('eslint')
    eslint_config.autostart = false
    eslint_config.priority = 50
    vim.lsp.config('eslint', eslint_config)

    -- Other web development servers
    vim.lsp.config('astro', load_server_config('astro'))
    vim.lsp.config('biome', load_server_config('biome'))

    -- General purpose servers
    vim.lsp.config('jsonls', load_server_config('jsonls'))
    vim.lsp.config('yamlls', load_server_config('yamlls'))
    vim.lsp.config('marksman', load_server_config('marksman'))
    vim.lsp.config('bashls', load_server_config('bashls'))
    vim.lsp.config('dockerls', load_server_config('dockerls'))

    vim.lsp.config('clangd', load_server_config('clangd'))
    vim.lsp.config('lua_ls', load_server_config('lua_ls'))

    -- Systems Programming
    vim.lsp.config('rust_analyzer', load_server_config('rust_analyzer'))
    vim.lsp.config('ols', load_server_config('ols'))

    -- Mobile/Flutter Development
    vim.lsp.config('dartls', load_server_config('dartls'))

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
