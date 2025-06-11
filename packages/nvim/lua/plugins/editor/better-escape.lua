-- Better escape plugin - allows escaping insert mode with key combinations like 'jk'
return {
  'jdhao/better-escape.vim',
  event = 'InsertEnter',
  config = function()
    -- Set escape shortcuts - supporting multiple combinations
    vim.g.better_escape_shortcut = { 'jk', 'jj' }

    -- Set time interval threshold in milliseconds
    vim.g.better_escape_interval = 120

    -- Enable debug mode to check timing (optional)
    vim.g.better_escape_debug = 0
  end,
}
