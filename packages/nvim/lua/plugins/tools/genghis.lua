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
  end,
}
