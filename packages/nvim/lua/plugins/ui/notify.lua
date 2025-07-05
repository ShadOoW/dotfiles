-- nvim-notify configuration
-- Provides compact, non-intrusive notification indicators with modern UX
return {
  'rcarriga/nvim-notify',
  lazy = false,
  priority = 800, -- Load after colorscheme but before noice
  config = function()
    local notify = require('notify')

    notify.setup({
      -- Background color for transparency calculations
      background_colour = '#1a1b26', -- Tokyo Night background

      -- Animation settings
      fps = 120,
      level = 2,
      minimum_width = 50,
      render = 'wrapped-compact',
      stages = 'static',
      timeout = 2000,
      top_down = true,

      -- Icons for different log levels
      icons = {
        ERROR = '',
        WARN = '',
        INFO = '',
        DEBUG = '',
        TRACE = '',
      },

      -- Window configuration
      max_height = function() return math.min(10, math.floor(vim.o.lines * 0.3)) end,
      max_width = function()
        -- Wider width - 80 characters or 40% of screen width
        local max_width_chars = 80
        local max_width_percent = math.floor(vim.o.columns * 0.4)
        return math.min(max_width_chars, max_width_percent)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, {
          zindex = 100,
        })
        -- Set window options for better readability
        vim.wo[win].wrap = true
        vim.wo[win].linebreak = true -- Break on words
        vim.wo[win].breakindent = true -- Preserve indentation when wrapping
        vim.wo[win].conceallevel = 2
        vim.wo[win].foldenable = false
        vim.wo[win].winhl = 'Normal:NotifyCompact'
      end,

      -- Mouse behavior
      on_close = function(win, timer)
        -- Only close if not focused
        if timer and vim.api.nvim_win_get_config(win).focusable then
          local focused = vim.api.nvim_get_current_win() == win
          if not focused then vim.api.nvim_win_close(win, true) end
        end
      end,
    })

    -- Override vim.notify to truncate long messages
    local original_notify = notify
    vim.notify = function(msg, level, opts)
      opts = opts or {}

      -- Convert message to string and clean it
      if type(msg) == 'table' then msg = table.concat(msg, ' ') end
      msg = tostring(msg or '')

      -- Aggressive truncation for brief indicators
      local max_chars = 80
      if #msg > max_chars then msg = msg:sub(1, max_chars - 3) .. '...' end

      -- Remove excessive whitespace and newlines
      msg = msg:gsub('%s*\n%s*', ' '):gsub('%s+', ' '):gsub('^%s*(.-)%s*$', '%1')

      -- Store full message in history for panel viewing
      local full_msg = opts.original_msg or msg
      if not opts.original_msg then opts.original_msg = full_msg end

      return original_notify(msg, level, opts)
    end

    -- Tokyo Night color integration with compact styling
    vim.api.nvim_set_hl(0, 'NotifyBackground', {
      bg = '#1a1b26',
    })

    -- Compact notification styling
    vim.api.nvim_set_hl(0, 'NotifyCompact', {
      bg = '#1a1b26',
      fg = '#c0caf5',
    })

    -- Error colors - more subtle
    vim.api.nvim_set_hl(0, 'NotifyERRORBorder', {
      fg = '#f7768e',
    })
    vim.api.nvim_set_hl(0, 'NotifyERRORIcon', {
      fg = '#f7768e',
    })
    vim.api.nvim_set_hl(0, 'NotifyERRORTitle', {
      fg = '#f7768e',
      bold = false, -- Less bold for compact look
    })
    vim.api.nvim_set_hl(0, 'NotifyERRORBody', {
      fg = '#c0caf5',
    })

    -- Warning colors
    vim.api.nvim_set_hl(0, 'NotifyWARNBorder', {
      fg = '#e0af68',
    })
    vim.api.nvim_set_hl(0, 'NotifyWARNIcon', {
      fg = '#e0af68',
    })
    vim.api.nvim_set_hl(0, 'NotifyWARNTitle', {
      fg = '#e0af68',
      bold = false,
    })
    vim.api.nvim_set_hl(0, 'NotifyWARNBody', {
      fg = '#c0caf5',
    })

    -- Info colors
    vim.api.nvim_set_hl(0, 'NotifyINFOBorder', {
      fg = '#7aa2f7',
    })
    vim.api.nvim_set_hl(0, 'NotifyINFOIcon', {
      fg = '#7aa2f7',
    })
    vim.api.nvim_set_hl(0, 'NotifyINFOTitle', {
      fg = '#7aa2f7',
      bold = false,
    })
    vim.api.nvim_set_hl(0, 'NotifyINFOBody', {
      fg = '#c0caf5',
    })

    -- Debug/Trace colors
    vim.api.nvim_set_hl(0, 'NotifyDEBUGBorder', {
      fg = '#565f89',
    })
    vim.api.nvim_set_hl(0, 'NotifyDEBUGIcon', {
      fg = '#565f89',
    })
    vim.api.nvim_set_hl(0, 'NotifyDEBUGTitle', {
      fg = '#565f89',
      bold = false,
    })
    vim.api.nvim_set_hl(0, 'NotifyDEBUGBody', {
      fg = '#c0caf5',
    })
    vim.api.nvim_set_hl(0, 'NotifyTRACEBorder', {
      fg = '#565f89',
    })
    vim.api.nvim_set_hl(0, 'NotifyTRACEIcon', {
      fg = '#565f89',
    })
    vim.api.nvim_set_hl(0, 'NotifyTRACETitle', {
      fg = '#565f89',
      bold = false,
    })
    vim.api.nvim_set_hl(0, 'NotifyTRACEBody', {
      fg = '#c0caf5',
    })
  end,
}
