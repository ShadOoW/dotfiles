-- Better escape plugin - allows escaping insert mode with key combinations like 'jk'
return {
  'max397574/better-escape.nvim',
  event = 'InsertEnter',
  config = function()
    require('better_escape').setup({
      -- Mapping to escape insert mode
      mapping = { 'asd', 'jk', 'jj' }, -- a table with mappings to use
      timeout = 120, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
      clear_empty_lines = false, -- clear line after escaping if there is only whitespace
      keys = '<Esc>', -- keys used for escaping, if it is a function will be called every time
    })
  end,
}
