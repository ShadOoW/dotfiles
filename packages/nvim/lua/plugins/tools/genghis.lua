-- File operations from within the buffer (Genghis)
-- Keymaps: fn=new fe=new-in-folder fs=from-selection fd=dup fr=rename fm=move fx=chmod fD=trash fp=path fy=name
return {
  'chrisgrieser/nvim-genghis',
  event = 'VeryLazy',
  dependencies = { 'stevearc/dressing.nvim' },
  config = function()
    require('genghis').setup({
      backdrop = {
        enabled = true,
        blend = 50,
      },
      notifyOnEmptyTrash = false,
    })

    vim.keymap.set('v', '<leader>fs', function() require('genghis').moveSelectionToNewFile() end, {
      desc = 'New from selection',
    })

    vim.keymap.set('n', '<leader>fx', '<cmd>Genghis chmodx<CR>', {
      desc = 'chmod +x',
    })

    -- Copy
    vim.keymap.set('n', '<leader>fY', '<cmd>Genghis copyFilepath<CR>', {
      desc = 'Copy path',
    })
    vim.keymap.set('n', '<leader>fy', '<cmd>Genghis copyFilename<CR>', {
      desc = 'Copy name',
    })
  end,
}
