return {
  'mbbill/undotree',
  cmd = { 'UndotreeToggle', 'UndotreeShow', 'UndotreeHide', 'UndotreeFocus' },
  keys = { {
    '<leader>xu',
    '<cmd>UndotreeToggle<CR>',
    desc = 'Toggle Undotree',
  } },
  config = function()
    vim.g.undotree_WindowLayout = 2
    vim.g.undotree_SplitWidth = 40
  end,
}
