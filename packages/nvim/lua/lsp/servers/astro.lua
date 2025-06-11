-- Astro LSP server configuration
local function get_typescript_server_path()
  local possible_paths = { -- Try astro-language-server's own TypeScript first
    vim.fn.stdpath('data') .. '/mason/packages/astro-language-server/node_modules/typescript/lib',
    -- Fallback to typescript-language-server
    vim.fn.stdpath('data') .. '/mason/packages/typescript-language-server/node_modules/typescript/lib',
    -- Try global TypeScript installation
    '/usr/lib/node_modules/typescript/lib', -- Try local node_modules
    vim.fn.getcwd() .. '/node_modules/typescript/lib',
  }

  for _, path in ipairs(possible_paths) do
    local tsserver_lib = path .. '/tsserverlibrary.js'
    if vim.fn.filereadable(tsserver_lib) == 1 then return path end
  end

  -- Default fallback
  return vim.fn.stdpath('data') .. '/mason/packages/astro-language-server/node_modules/typescript/lib'
end

return {
  filetypes = { 'astro' },
  init_options = {
    typescript = {
      tsdk = get_typescript_server_path(),
    },
  },
  settings = {
    astro = {
      format = {
        indentFrontmatter = false,
      },
      typescript = {
        enabled = true,
      },
      preferences = {
        quotePreference = 'single',
      },
    },
  },
  root_dir = function(fname)
    return require('lspconfig.util').root_pattern(
      'astro.config.mjs',
      'astro.config.js',
      'astro.config.ts',
      'package.json',
      '.git'
    )(fname)
  end,
  single_file_support = true,
}
