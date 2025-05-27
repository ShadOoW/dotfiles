return {
  'tpope/vim-fugitive',
  cmd = {
    'Git',
    'Gdiffsplit',
    'Gread',
    'Gwrite',
    'Ggrep',
    'GMove',
    'GDelete',
    'GBrowse',
    'GRemove',
    'GRename',
  },
  event = 'VeryLazy',
  config = function()
    -- Optional: Add keymaps or custom config here
  end,
}
