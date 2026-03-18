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

    -- Global config applied to every server
    vim.lsp.config('*', {
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      on_attach = handlers.on_attach,
    })

    -- Per-server overrides (loaded from lsp/servers/<name>.lua)
    local server_names = {
      'superhtml', 'cssls', 'vtsls', 'eslint', 'astro',
      'jsonls', 'yamlls', 'marksman', 'bashls', 'dockerls', 'clangd',
      'lua_ls', 'rust_analyzer', 'ols', 'dartls',
    }

    for _, name in ipairs(server_names) do
      local ok, server_config = pcall(require, 'lsp.servers.' .. name)
      if ok and server_config and type(server_config) == 'table' then
        -- Force strict opt-in for noisy servers
        if name == 'eslint' or name == 'biome' then
          server_config.single_file_support = false
        end
        vim.lsp.config(name, server_config)
      end
    end

    -- Enable all servers (tailwindcss intentionally excluded — opt-in only)
    vim.lsp.enable(server_names)

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
