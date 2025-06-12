-- Modern cursor configuration - slim and clean with mode-specific colors
local M = {}

function M.setup()
  -- Set cursor options for different modes with mode-specific colors
  vim.opt.guicursor = {
    'n-c:block-Cursor/lCursor', -- Normal, Command: block cursor (blue)
    'v:block-vCursor/lCursor', -- Visual: block cursor (purple)
    'i-ci-ve:ver1-lCursor/lCursor', -- Insert: ultra-slim vertical bar like VSCode (green)
    'r-cr:hor20-Cursor/lCursor', -- Replace: thin horizontal bar
    'o:hor50-Cursor/lCursor', -- Operator pending: medium horizontal bar
    'a:blinkwait700-blinkoff400-blinkon250', -- All modes: cursor blinking
    'sm:block-Cursor/lCursor-blinkwait175-blinkoff150-blinkon175', -- Show match: block
  }

  -- Create custom cursor highlight groups matching statusline mode colors
  local function set_cursor_highlights()
    -- Normal mode cursor - tokyo night blue
    vim.api.nvim_set_hl(0, 'Cursor', {
      fg = '#1a1b26', -- tokyo night background
      bg = '#7aa2f7', -- tokyo night blue to match normal mode statusline
      blend = 15,
    })

    -- Insert mode cursor - tokyo night green (matches statusline insert)
    vim.api.nvim_set_hl(0, 'lCursor', {
      fg = '#1a1b26',
      bg = '#9ece6a', -- tokyo night green - matches insert mode statusline
      blend = 10,
    })

    -- Visual mode cursor - tokyo night purple (matches statusline visual)
    vim.api.nvim_set_hl(0, 'vCursor', {
      fg = '#1a1b26',
      bg = '#bb9af7', -- tokyo night purple - matches visual mode statusline
      blend = 10,
    })

    -- Terminal cursor
    vim.api.nvim_set_hl(0, 'TermCursor', {
      fg = '#1a1b26',
      bg = '#f7768e', -- tokyo night red
      blend = 15,
    })

    -- No cursor (invisible)
    vim.api.nvim_set_hl(0, 'TermCursorNC', {
      fg = 'NONE',
      bg = 'NONE',
      blend = 100, -- Fully transparent
    })
  end

  -- Set highlights immediately
  set_cursor_highlights()

  -- Re-apply highlights when colorscheme changes
  vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    callback = set_cursor_highlights,
    desc = 'Update cursor highlights after colorscheme change',
  })

  -- Additional cursor behavior tweaks
  vim.opt.cursorline = true -- Highlight the line with cursor
  vim.opt.cursorcolumn = false -- Don't highlight the column (cleaner look)

  -- Smooth cursor movement (if supported by terminal)
  if vim.fn.exists('+termguicolors') == 1 then vim.opt.termguicolors = true end

  -- Simplified mode-aware cursor color updates with immediate visual feedback
  vim.api.nvim_create_autocmd('ModeChanged', {
    pattern = '*',
    callback = function()
      local mode = vim.fn.mode()
      -- Immediate cursor highlight update based on mode
      if mode == 'i' or mode == 'ic' or mode == 'ix' then
        -- Insert mode - green cursor
        vim.cmd('highlight! link Cursor lCursor')
      elseif mode == 'v' or mode == 'V' or mode == '' then
        -- Visual mode - purple cursor with immediate effect
        vim.cmd('highlight! link Cursor vCursor')
        -- Force immediate redraw for visual mode
        vim.cmd('redraw!')
      else
        -- Normal/other modes - blue cursor
        set_cursor_highlights() -- Reset to default
      end
    end,
    desc = 'Update cursor color based on current mode',
  })

  -- Additional autocmd specifically for visual mode entry to ensure immediate color change
  vim.api.nvim_create_autocmd('ModeChanged', {
    pattern = '*:v*', -- Any mode to visual mode
    callback = function()
      vim.cmd('highlight! link Cursor vCursor')
      -- Multiple redraw attempts to ensure immediate visual feedback
      vim.cmd('redraw!')
      vim.schedule(function() vim.cmd('redraw!') end)
    end,
    desc = 'Immediate visual mode cursor color change',
  })
end

return M
