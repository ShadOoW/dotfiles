-- Enhanced notification system with better integration
return {
  'rcarriga/nvim-notify',
  event = 'VeryLazy',
  config = function()
    local notify = require('notify')

    notify.setup({
      -- Animation style
      stages = 'fade_in_slide_out',

      -- Timeout for notifications
      timeout = 3000,

      -- Background colour
      background_colour = '#1e1e2e',

      -- Icons for different log levels
      icons = {
        ERROR = '',
        WARN = '',
        INFO = '',
        DEBUG = '',
        TRACE = '✎',
      },

      -- Minimum width and maximum width
      minimum_width = 50,
      maximum_width = 80,

      -- Level of notifications to show
      level = vim.log.levels.INFO,

      -- Function called when a new window is opened
      on_open = function(win)
        vim.api.nvim_win_set_config(win, {
          zindex = 100,
        })
      end,

      -- Function called when a window is closed
      on_close = function() end,

      -- Render function for notifications
      render = 'default',

      -- Top down or bottom up
      top_down = true,
    })

    -- Set as default notify function
    vim.notify = notify

    -- Enhanced notification functions
    local M = {}

    -- Build status notifications
    function M.build_started(project_name)
      notify(string.format('🔨 Building %s...', project_name or 'project'), vim.log.levels.INFO, {
        title = 'Build Started',
        timeout = 2000,
      })
    end

    function M.build_success(project_name, duration)
      local message = string.format('✅ Build successful for %s', project_name or 'project')
      if duration then message = message .. string.format(' (%.1fs)', duration) end

      notify(message, vim.log.levels.INFO, {
        title = 'Build Success',
        timeout = 3000,
      })
    end

    function M.build_failed(project_name, error_msg)
      local message = string.format('❌ Build failed for %s', project_name or 'project')
      if error_msg then message = message .. '\n' .. error_msg end

      notify(message, vim.log.levels.ERROR, {
        title = 'Build Failed',
        timeout = 5000,
      })
    end

    -- Test notifications
    function M.test_started(test_name)
      notify(string.format('🧪 Running tests: %s', test_name or 'all'), vim.log.levels.INFO, {
        title = 'Tests Started',
        timeout = 2000,
      })
    end

    function M.test_passed(passed, total, duration)
      local message = string.format('✅ %d/%d tests passed', passed, total)
      if duration then message = message .. string.format(' (%.1fs)', duration) end

      notify(message, vim.log.levels.INFO, {
        title = 'Tests Passed',
        timeout = 3000,
      })
    end

    function M.test_failed(failed, total, duration)
      local message = string.format('❌ %d/%d tests failed', failed, total)
      if duration then message = message .. string.format(' (%.1fs)', duration) end

      notify(message, vim.log.levels.ERROR, {
        title = 'Tests Failed',
        timeout = 5000,
      })
    end

    -- LSP notifications
    function M.lsp_attached(client_name, buffer_name)
      notify(string.format('🔧 %s attached to %s', client_name, buffer_name or 'buffer'), vim.log.levels.INFO, {
        title = 'LSP Attached',
        timeout = 2000,
      })
    end

    function M.lsp_detached(client_name)
      notify(string.format('🔧 %s detached', client_name), vim.log.levels.WARN, {
        title = 'LSP Detached',
        timeout = 2000,
      })
    end

    function M.lsp_error(client_name, error_msg)
      notify(string.format('🔧 %s error: %s', client_name, error_msg), vim.log.levels.ERROR, {
        title = 'LSP Error',
        timeout = 5000,
      })
    end

    -- Debug notifications
    function M.debug_started(config_name)
      notify(string.format('🐛 Debug session started: %s', config_name or 'default'), vim.log.levels.INFO, {
        title = 'Debug Started',
        timeout = 2000,
      })
    end

    function M.debug_stopped()
      notify('🐛 Debug session stopped', vim.log.levels.INFO, {
        title = 'Debug Stopped',
        timeout = 2000,
      })
    end

    function M.debug_breakpoint_hit(file, line)
      notify(string.format('🐛 Breakpoint hit at %s:%d', vim.fn.fnamemodify(file, ':t'), line), vim.log.levels.INFO, {
        title = 'Breakpoint Hit',
        timeout = 3000,
      })
    end

    -- Project notifications
    function M.project_switched(project_name, project_type)
      local icon = '📁'
      if project_type == 'gradle' then
        icon = '📦'
      elseif project_type == 'maven' then
        icon = '📦'
      elseif project_type == 'node' then
        icon = '📦'
      elseif project_type == 'rust' then
        icon = '🦀'
      elseif project_type == 'python' then
        icon = '🐍'
      elseif project_type == 'go' then
        icon = '🐹'
      end

      notify(string.format('%s Switched to %s', icon, project_name), vim.log.levels.INFO, {
        title = 'Project Switched',
        timeout = 2000,
      })
    end

    -- Git notifications
    function M.git_branch_switched(branch_name)
      notify(string.format(' Switched to branch: %s', branch_name), vim.log.levels.INFO, {
        title = 'Git Branch',
        timeout = 2000,
      })
    end

    function M.git_commit_success(commit_hash)
      notify(string.format(' Commit successful: %s', commit_hash:sub(1, 7)), vim.log.levels.INFO, {
        title = 'Git Commit',
        timeout = 3000,
      })
    end

    -- File operations
    function M.file_saved(filename)
      notify(string.format('💾 Saved: %s', vim.fn.fnamemodify(filename, ':t')), vim.log.levels.INFO, {
        title = 'File Saved',
        timeout = 1000,
      })
    end

    function M.file_formatted(formatter_name)
      notify(string.format('✨ Formatted with %s', formatter_name), vim.log.levels.INFO, {
        title = 'File Formatted',
        timeout = 1500,
      })
    end

    -- Plugin notifications
    function M.plugin_loaded(plugin_name)
      notify(string.format('🔌 Loaded: %s', plugin_name), vim.log.levels.INFO, {
        title = 'Plugin Loaded',
        timeout = 1000,
      })
    end

    function M.plugin_error(plugin_name, error_msg)
      notify(string.format('🔌 Error loading %s: %s', plugin_name, error_msg), vim.log.levels.ERROR, {
        title = 'Plugin Error',
        timeout = 5000,
      })
    end

    -- Utility functions
    function M.dismiss_all()
      notify.dismiss({
        silent = true,
        pending = true,
      })
    end

    function M.show_history()
      local themes = require('telescope.themes')
      require('telescope').extensions.notify.notify(themes.get_ivy({
        prompt_title = '📜 Notification History',
        layout_config = {
          height = 0.4,
          preview_cutoff = 120,
        },
      }))
    end

    -- Setup auto-commands for automatic notifications
    local notify_group = vim.api.nvim_create_augroup('EnhancedNotifications', {
      clear = true,
    })

    -- LSP attach/detach notifications
    vim.api.nvim_create_autocmd('LspAttach', {
      group = notify_group,
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then M.lsp_attached(client.name, vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ':t')) end
      end,
    })

    -- File save notifications (optional, can be disabled if too noisy)
    vim.api.nvim_create_autocmd('BufWritePost', {
      group = notify_group,
      callback = function(args) M.file_saved(vim.api.nvim_buf_get_name(args.buf)) end,
    })

    -- Project change notifications
    vim.api.nvim_create_autocmd('User', {
      pattern = 'ProjectChanged',
      group = notify_group,
      callback = function()
        local cwd = vim.fn.getcwd()
        local project_name = vim.fn.fnamemodify(cwd, ':t')

        -- Detect project type
        local project_type = 'unknown'
        if _G.ProjectSwitcher then
          local type_info = _G.ProjectSwitcher.detect_project_type(cwd)
          project_type = type_info.type
        end

        M.project_switched(project_name, project_type)
      end,
    })

    -- DAP notifications
    vim.api.nvim_create_autocmd('User', {
      pattern = 'DapSessionStarted',
      group = notify_group,
      callback = function() M.debug_started() end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'DapSessionStopped',
      group = notify_group,
      callback = function() M.debug_stopped() end,
    })

    -- Commands
    vim.api.nvim_create_user_command('NotifyDismiss', M.dismiss_all, {
      desc = 'Dismiss all notifications',
    })

    vim.api.nvim_create_user_command('NotifyHistory', M.show_history, {
      desc = 'Show notification history',
    })

    -- Keymaps
    vim.keymap.set('n', '<leader>An', M.dismiss_all, {
      desc = 'Dismiss Notifications',
    })

    -- Export for other plugins to use
    _G.EnhancedNotify = M

    -- Integration with telescope for notification history
    pcall(require('telescope').load_extension, 'notify')
  end,
}
