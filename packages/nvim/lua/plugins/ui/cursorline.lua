-- Enhanced cursorline (replaces mini.cursorline)
return {
  'yamatsum/nvim-cursorline',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require('nvim-cursorline').setup({
      cursorline = {
        enable = true,
        timeout = 1000,
        number = false,
      },
      cursorword = {
        enable = true,
        min_length = 3,
        hl = {
          underline = true,
        },
      },
    })

    -- Subtle cursorword highlighting - no background, just underline
    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = '*',
      callback = function()
        -- Set subtle highlight for cursorword - just underline
        vim.api.nvim_set_hl(0, 'CursorWord', {
          underline = true,
          sp = '#7aa2f7', -- Tokyo night blue for underline color
        })
      end,
      desc = 'Update CursorWord highlight after colorscheme change',
    })

    -- Apply immediately - subtle underline only
    vim.api.nvim_set_hl(0, 'CursorWord', {
      underline = true,
      sp = '#7aa2f7', -- Tokyo night blue for underline color
    })
  end,
}
