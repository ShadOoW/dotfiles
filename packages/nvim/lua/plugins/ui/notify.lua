-- Enhanced notification backend using nvim-notify
-- Provides beautiful, customizable notifications with Tokyo Night styling
return {
  'rcarriga/nvim-notify',
  event = 'VeryLazy',
  config = function()
    local notify = require('notify')

    -- Configure notify: passive (panel-first model; popups only for critical errors)
    notify.setup({
      stages = 'static',
      timeout = false,
      max_height = function() return math.floor(vim.o.lines * 0.75) end,
      max_width = function() return math.floor(vim.o.columns * 0.75) end,
      minimum_width = 50,

      -- Layout and positioning
      background_colour = '#1e1e2e',
      fps = 60,
      level = 2,

      -- Rendering options
      render = 'wrapped-compact',

      -- Top-down notification stacking
      top_down = true,

      -- Icons for different log levels
      icons = {
        ERROR = ' ',
        WARN = ' ',
        INFO = ' ',
        DEBUG = ' ',
        TRACE = ' ',
      },

      -- Time format
      time_formats = {
        notification = '%T',
        notification_history = '%FT%T',
      },

      -- Notification window styling
      on_open = function(win)
        vim.api.nvim_win_set_config(win, {
          zindex = 100,
        })

        -- Set window-specific highlight groups
        vim.api.nvim_win_set_option(win, 'winhl', 'Normal:NotifyBackground,FloatBorder:NotifyBorder')
      end,

      -- Custom highlight groups
      highlight = {
        error = 'NotifyERROR',
        warn = 'NotifyWARN',
        info = 'NotifyINFO',
        debug = 'NotifyDEBUG',
        trace = 'NotifyTRACE',
      },
    })

    -- Set up Tokyo Night inspired highlight groups
    local function setup_highlights()
      -- Base notification colors
      vim.api.nvim_set_hl(0, 'NotifyBackground', {
        fg = '#cdd6f4',
        bg = '#1e1e2e',
      })
      local bg_dark = '#16161e'
      vim.api.nvim_set_hl(0, 'NotifyBorder', {
        fg = '#89b4fa',
        bg = bg_dark,
      })

      -- Level-specific colors
      vim.api.nvim_set_hl(0, 'NotifyERROR', {
        fg = '#f38ba8',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'NotifyWARN', {
        fg = '#f9e2af',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'NotifyINFO', {
        fg = '#89b4fa',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'NotifyDEBUG', {
        fg = '#6c7086',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'NotifyTRACE', {
        fg = '#6c7086',
        bg = '#1e1e2e',
      })

      -- Border colors for different levels (solid backgrounds)
      vim.api.nvim_set_hl(0, 'NotifyERRORBorder', {
        fg = '#f38ba8',
        bg = bg_dark,
      })
      vim.api.nvim_set_hl(0, 'NotifyWARNBorder', {
        fg = '#f9e2af',
        bg = bg_dark,
      })
      vim.api.nvim_set_hl(0, 'NotifyINFOBorder', {
        fg = '#89b4fa',
        bg = bg_dark,
      })
      vim.api.nvim_set_hl(0, 'NotifyDEBUGBorder', {
        fg = '#6c7086',
        bg = bg_dark,
      })
      vim.api.nvim_set_hl(0, 'NotifyTRACEBorder', {
        fg = '#6c7086',
        bg = bg_dark,
      })

      -- Title colors
      vim.api.nvim_set_hl(0, 'NotifyERRORTitle', {
        fg = '#f38ba8',
        bg = '#1e1e2e',
        bold = true,
      })
      vim.api.nvim_set_hl(0, 'NotifyWARNTitle', {
        fg = '#f9e2af',
        bg = '#1e1e2e',
        bold = true,
      })
      vim.api.nvim_set_hl(0, 'NotifyINFOTitle', {
        fg = '#89b4fa',
        bg = '#1e1e2e',
        bold = true,
      })
      vim.api.nvim_set_hl(0, 'NotifyDEBUGTitle', {
        fg = '#6c7086',
        bg = '#1e1e2e',
        bold = true,
      })
      vim.api.nvim_set_hl(0, 'NotifyTRACETitle', {
        fg = '#6c7086',
        bg = '#1e1e2e',
        bold = true,
      })

      -- Icon colors
      vim.api.nvim_set_hl(0, 'NotifyERRORIcon', {
        fg = '#f38ba8',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'NotifyWARNIcon', {
        fg = '#f9e2af',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'NotifyINFOIcon', {
        fg = '#89b4fa',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'NotifyDEBUGIcon', {
        fg = '#6c7086',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'NotifyTRACEIcon', {
        fg = '#6c7086',
        bg = '#1e1e2e',
      })

      -- Body text colors
      vim.api.nvim_set_hl(0, 'NotifyERRORBody', {
        fg = '#cdd6f4',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'NotifyWARNBody', {
        fg = '#cdd6f4',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'NotifyINFOBody', {
        fg = '#cdd6f4',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'NotifyDEBUGBody', {
        fg = '#bac2de',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'NotifyTRACEBody', {
        fg = '#bac2de',
        bg = '#1e1e2e',
      })
    end

    -- Apply highlights immediately and on colorscheme change
    setup_highlights()
    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = setup_highlights,
    })

    -- Set nvim-notify as the default notification handler
    vim.notify = notify

    -- Create utility functions for notification management
    _G.notification_utils = {
      -- Get notification history with filtering
      get_history = function(filters)
        filters = filters or {}
        local history = notify.history()

        if filters.level then
          history = vim.tbl_filter(function(notif) return notif.level == filters.level end, history)
        end

        if filters.since then
          local since_time = os.time() - filters.since
          history = vim.tbl_filter(function(notif) return notif.time and notif.time >= since_time end, history)
        end

        return history
      end,

      -- Count notifications by severity
      count_by_severity = function(since_seconds)
        since_seconds = since_seconds or 300 -- Default 5 minutes
        local history = notify.history()
        local counts = {
          error = 0,
          warn = 0,
          info = 0,
          debug = 0,
          trace = 0,
        }
        local current_time = os.time()

        -- Create reverse lookup for log levels
        local level_names = {}
        for name, level in pairs(vim.log.levels) do
          level_names[level] = name:lower()
        end

        for _, notif in ipairs(history) do
          if notif.time and notif.level and not notif.dismissed then
            local age = current_time - notif.time
            if age <= since_seconds then
              local level_name = level_names[notif.level]
              if level_name and counts[level_name] then counts[level_name] = counts[level_name] + 1 end
            end
          end
        end

        return counts
      end,

      -- Dismiss notifications by criteria
      dismiss_by_criteria = function(criteria)
        criteria = criteria or {}
        local history = notify.history()

        for _, notif in ipairs(history) do
          local should_dismiss = true

          if criteria.level and notif.level ~= criteria.level then should_dismiss = false end

          if criteria.title and notif.title ~= criteria.title then should_dismiss = false end

          if criteria.older_than then
            local age = os.time() - (notif.time or 0)
            if age < criteria.older_than then should_dismiss = false end
          end

          if should_dismiss then
            notify.dismiss({
              silent = true,
              pending = true,
            })
            break
          end
        end
      end,

      -- Clear old notifications automatically
      auto_clear_old = function(max_age)
        max_age = max_age or 600 -- Default 10 minutes
        _G.notification_utils.dismiss_by_criteria({
          older_than = max_age,
        })
      end,
    }

    -- Setup auto-clear timer for old notifications
    local auto_clear_timer = vim.loop.new_timer()
    auto_clear_timer:start(60000, 60000, vim.schedule_wrap(function() _G.notification_utils.auto_clear_old() end))

    -- Create autocmd to emit custom event for lualine integration
    vim.api.nvim_create_autocmd('User', {
      pattern = 'NotifyBackground',
      callback = function()
        vim.schedule(function() vim.cmd('redrawstatus') end)
      end,
    })
  end,
}
