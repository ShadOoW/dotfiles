-- File operations from within the buffer
-- Provides convenient file operations like rename, move, copy, etc.
return {
  'chrisgrieser/nvim-genghis',
  event = 'VeryLazy',
  dependencies = { 'stevearc/dressing.nvim' }, -- For better UI
  config = function()
    -- Setup genghis with proper configuration
    require('genghis').setup({
      backdrop = {
        enabled = true,
        blend = 50,
      },
      -- Ensure we have proper error handling
      notifyOnEmptyTrash = false,
    })

    -- File operations keymaps
    vim.keymap.set('n', '<leader>Fp', '<cmd>Genghis copyFilepath<CR>', {
      desc = 'Copy file path',
    })

    vim.keymap.set('n', '<leader>Fy', '<cmd>Genghis copyFilename<CR>', {
      desc = 'Copy filename',
    })

    vim.keymap.set('n', '<leader>Fd', '<cmd>Genghis duplicateFile<CR>', {
      desc = 'Duplicate file',
    })

    vim.keymap.set('n', '<leader>Fr', '<cmd>Genghis renameFile<CR>', {
      desc = 'Rename file',
    })

    vim.keymap.set('n', '<leader>Fx', '<cmd>Genghis chmodx<CR>', {
      desc = 'Make file executable',
    })

    vim.keymap.set('v', '<leader>Ff', ':\'<,\'>Genghis newFileFromSelection<CR>', {
      desc = 'New file from selection',
    })

    vim.keymap.set('n', '<leader>Fm', '<cmd>Genghis moveFile<CR>', {
      desc = 'Move file',
    })

    vim.keymap.set('n', '<leader>Ft', '<cmd>Genghis trashFile<CR>', {
      desc = 'Trash file',
    })

    vim.keymap.set('v', '<leader>FR', ':\'<,\'>Genghis renameFileToSelection<CR>', {
      desc = 'Rename file to selection',
    })
  end,
}
