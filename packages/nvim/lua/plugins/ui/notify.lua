-- nvim-notify configuration
-- Provides beautiful notification popups with proper transparency support
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
      fps = 30,
      level = 2,
      minimum_width = 50,
      render = 'wrapped-compact',
      stages = 'fade_in_slide_out',
      timeout = 5000,
      top_down = true,

      -- Icons for different log levels
      icons = {
        ERROR = '󰅚',
        WARN = '󰀪',
        INFO = '󰋽',
        DEBUG = '󰌶',
        TRACE = '󰌶',
      },

      -- Window configuration with max width constraint
      max_height = function() return math.floor(vim.o.lines * 0.75) end,
      max_width = function()
        -- Set max width to 60 characters or 40% of screen width, whichever is smaller
        local max_width_chars = 40
        local max_width_percent = math.floor(vim.o.columns * 0.3)
        return math.min(max_width_chars, max_width_percent)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, {
          zindex = 100,
        })
      end,
    })

    -- Set nvim-notify as the default notification handler
    vim.notify = notify

    -- Tokyo Night color integration
    vim.api.nvim_set_hl(0, 'NotifyBackground', {
      bg = '#1a1b26',
    })
    vim.api.nvim_set_hl(0, 'NotifyERRORBorder', {
      fg = '#f7768e',
    })
    vim.api.nvim_set_hl(0, 'NotifyWARNBorder', {
      fg = '#e0af68',
    })
    vim.api.nvim_set_hl(0, 'NotifyINFOBorder', {
      fg = '#7aa2f7',
    })
    vim.api.nvim_set_hl(0, 'NotifyDEBUGBorder', {
      fg = '#565f89',
    })
    vim.api.nvim_set_hl(0, 'NotifyTRACEBorder', {
      fg = '#565f89',
    })
    vim.api.nvim_set_hl(0, 'NotifyERRORIcon', {
      fg = '#f7768e',
    })
    vim.api.nvim_set_hl(0, 'NotifyWARNIcon', {
      fg = '#e0af68',
    })
    vim.api.nvim_set_hl(0, 'NotifyINFOIcon', {
      fg = '#7aa2f7',
    })
    vim.api.nvim_set_hl(0, 'NotifyDEBUGIcon', {
      fg = '#565f89',
    })
    vim.api.nvim_set_hl(0, 'NotifyTRACEIcon', {
      fg = '#565f89',
    })
    vim.api.nvim_set_hl(0, 'NotifyERRORTitle', {
      fg = '#f7768e',
      bold = true,
    })
    vim.api.nvim_set_hl(0, 'NotifyWARNTitle', {
      fg = '#e0af68',
      bold = true,
    })
    vim.api.nvim_set_hl(0, 'NotifyINFOTitle', {
      fg = '#7aa2f7',
      bold = true,
    })
    vim.api.nvim_set_hl(0, 'NotifyDEBUGTitle', {
      fg = '#565f89',
      bold = true,
    })
    vim.api.nvim_set_hl(0, 'NotifyTRACETitle', {
      fg = '#565f89',
      bold = true,
    })
    vim.api.nvim_set_hl(0, 'NotifyERRORBody', {
      fg = '#c0caf5',
    })
    vim.api.nvim_set_hl(0, 'NotifyWARNBody', {
      fg = '#c0caf5',
    })
    vim.api.nvim_set_hl(0, 'NotifyINFOBody', {
      fg = '#c0caf5',
    })
    vim.api.nvim_set_hl(0, 'NotifyDEBUGBody', {
      fg = '#c0caf5',
    })
    vim.api.nvim_set_hl(0, 'NotifyTRACEBody', {
      fg = '#c0caf5',
    })
  end,
}
