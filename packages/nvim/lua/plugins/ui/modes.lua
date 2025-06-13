-- Enhanced mode indicators with perfect tokyo night colors
return {
  'mvllow/modes.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require('modes').setup({
      colors = {
        copy = '#ff9e64', -- Tokyo night orange - for yank/copy
        delete = '#f7768e', -- Tokyo night red - for delete operations
        insert = '#9ece6a', -- Tokyo night green - matches statusline insert
        visual = '#bb9af7', -- Tokyo night purple - matches statusline visual
      },

      -- Increased opacity for better visibility
      line_opacity = 0.25,

      -- Enable all visual indicators
      set_cursor = true,
      set_cursorline = true,
      set_number = true,

      -- Disable in special buffers for clean experience
      ignore_filetypes = { 'NvimTree', 'TelescopePrompt', 'lazy', 'mason', 'trouble', 'neo-tree' },
    })
  end,
}
