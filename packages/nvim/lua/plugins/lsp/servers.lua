-- LSP servers configuration
return {
  'neovim/nvim-lspconfig',
  dependencies = { 'hrsh7th/cmp-nvim-lsp', 'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim' },
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    -- Guard against double-loading due to lazy.nvim import/require overlap
    if _G.lsp_servers_setup_done then return end
    _G.lsp_servers_setup_done = true

    -- Load lspconfig to register server configurations
    local lspconfig = require('lspconfig')
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

    -- Function to setup a server using lspconfig
    local function setup_server(name)
      local config = load_server_config(name)
      
      -- Force strict opt-in for problematic servers if not already set
      if name == 'tailwindcss' or name == 'eslint' or name == 'biome' then
        config.single_file_support = false
        config.workspace_required = true
      end

      lspconfig[name].setup(config)
    end

    -- Setup all servers
    setup_server('superhtml')
    setup_server('cssls')
    -- Consolidate tailwind setup to be strictly opt-in
    setup_server('tailwindcss')
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
        -- Ensure treesitter parser is available
        vim.schedule(function() vim.cmd('TSBufEnable highlight') end)
      end,
      desc = 'Force HTML filetype detection for consistent LSP/treesitter behavior',
    })
  end,
}
