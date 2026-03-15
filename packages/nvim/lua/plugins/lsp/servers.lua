-- LSP servers configuration
return {
  'neovim/nvim-lspconfig',
  dependencies = { 'hrsh7th/cmp-nvim-lsp', 'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim' },
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    -- Guard against double-loading due to lazy.nvim import/require overlap
    if _G.lsp_servers_setup_done then return end
    _G.lsp_servers_setup_done = true

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
      if ok and server_config and type(server_config) == 'table' then
        return vim.tbl_deep_extend('force', common_settings, server_config)
      end
      return common_settings
    end

    -- Load lspconfig first - this registers server configs but triggers deprecation warning
    -- The warning is expected and acceptable until nvim-lspconfig v3.0.0
    local lspconfig = require('lspconfig')

    -- Setup servers
    local server_names = {
      'superhtml', 'cssls', 'vtsls', 'eslint', 'astro',
      'jsonls', 'yamlls', 'marksman', 'bashls', 'dockerls', 'clangd',
      'lua_ls', 'rust_analyzer', 'ols', 'dartls'
    }

    -- Disable tailwindcss auto-start AFTER setting up other servers
    vim.lsp._enabled_configs.tailwindcss = nil

    -- Function to setup a server using lspconfig
    local function setup_server(name)
      local config = load_server_config(name)

      -- Force strict opt-in for problematic servers
      if name == 'eslint' or name == 'biome' then
        config.single_file_support = false
      end

      lspconfig[name].setup(config)
    end

    -- Setup all servers
    setup_server('superhtml')
    setup_server('cssls')
    setup_server('vtsls')
    setup_server('eslint')
    setup_server('astro')
    setup_server('jsonls')
    setup_server('yamlls')
    setup_server('marksman')
    setup_server('bashls')
    setup_server('dockerls')
    setup_server('clangd')
    setup_server('lua_ls')
    setup_server('rust_analyzer')
    setup_server('ols')
    setup_server('dartls')

    -- Force HTML filetype detection for consistency
    vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
      pattern = { '*.html', '*.htm', '*.xhtml' },
      callback = function(args)
        vim.bo[args.buf].filetype = 'html'
        vim.schedule(function() vim.cmd('TSBufEnable highlight') end)
      end,
      desc = 'Force HTML filetype detection for consistent LSP/treesitter behavior',
    })
  end,
}
