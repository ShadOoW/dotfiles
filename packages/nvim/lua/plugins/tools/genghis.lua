-- nvim-genghis: File operations from within the buffer
return {
  'chrisgrieser/nvim-genghis',
  event = 'VeryLazy',
  dependencies = {
    'stevearc/dressing.nvim', -- For better UI
  },
  init = function()
    -- Set up keymaps for genghis
    -- File operations
    vim.keymap.set('n', '<leader>fp', '<cmd>Genghis copyFilepath<CR>', {
      desc = 'Copy filepath',
    })
    vim.keymap.set('n', '<leader>fy', '<cmd>Genghis copyFilename<CR>', {
      desc = 'Copy filename',
    })
    vim.keymap.set('n', '<leader>fd', '<cmd>Genghis duplicateFile<CR>', {
      desc = 'Duplicate file',
    })
    vim.keymap.set('n', '<leader>fn', '<cmd>Genghis renameFile<CR>', {
      desc = 'Rename file',
    })

    -- Buffer-local
    vim.keymap.set('n', '<leader>fx', '<cmd>Genghis chmodx<CR>', {
      desc = 'Make file executable',
    })

    -- Visual selection
    vim.keymap.set('v', '<leader>nf', ':\'<,\'>Genghis newFileFromSelection<CR>', {
      desc = 'New file from visual selection',
    })
  end,
}
