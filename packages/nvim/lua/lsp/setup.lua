-- LSP setup
local M = {}
local file_utils = require('utils.file')

function M.setup()
  local lspconfig = require('lspconfig')
  local handlers = require('lsp.handlers')

  -- Configure diagnostics
  handlers.setup_diagnostics()

  -- Load server configurations from the servers/ directory
  -- Each file should return a table with server configuration
  local servers_path = vim.fn.stdpath('config') .. '/lua/lsp/servers'
  local servers = {}

  -- Default server configuration with shared capabilities
  local default_config = {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    on_attach = handlers.on_attach,
  }

  -- Lua LSP default configuration (can be overridden in lsp/servers/lua_ls.lua)
  servers.lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        workspace = {
          checkThirdParty = false,
          library = vim.api.nvim_get_runtime_file('', true),
        },
        telemetry = {
          enable = false,
        },
      },
    },
  }

  -- Merge default config with server-specific config and set up servers
  for server_name, server_config in pairs(servers) do
    local config = vim.tbl_deep_extend('force', default_config, server_config or {})
    lspconfig[server_name].setup(config)
  end

  -- Check for server-specific configuration files
  local server_files = vim.fn.glob(servers_path .. '/*.lua', false, true)
  for _, file in ipairs(server_files) do
    local server_name = vim.fn.fnamemodify(file, ':t:r')

    -- Require the server configuration if the file exists
    if file_utils.file_exists(file) then
      local ok, server_config = pcall(require, 'lsp.servers.' .. server_name)
      if ok and server_config then
        local config = vim.tbl_deep_extend('force', default_config, server_config)
        lspconfig[server_name].setup(config)
      end
    end
  end
end

return M
