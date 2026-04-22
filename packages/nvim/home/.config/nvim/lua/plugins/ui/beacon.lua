-- Enhanced cursor animation with guaranteed visual feedback
return {
  'rainbowhxch/beacon.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require('beacon').setup({
      minimal_jump = 5, -- Lower threshold for more frequent triggers
      size = 60, -- Larger size for better visibility
      fade = true,
      speed = 3, -- Faster animation
      width = 60,
      winblend = 0, -- Fully opaque for readability
      cursor_events = { 'CursorMoved', 'CursorMovedI' }, -- Include insert mode
      window_events = { 'WinEnter', 'FocusGained', 'BufEnter' },
      highlight = {
        bg = '#7aa2f7', -- Tokyo night blue
        fg = '#c0caf5', -- Tokyo night foreground for contrast
        ctermbg = 12,
        ctermfg = 15,
      },
    })
  end,
}
