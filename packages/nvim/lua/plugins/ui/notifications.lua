-- Enhanced notification system using centralized utility
return {
  'rcarriga/nvim-notify',
  event = 'VeryLazy',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    -- Initialize the centralized notification system
    local notify_util = require('utils.notify')
    notify_util.setup()

    -- Setup auto-commands for automatic notifications
    local notify_group = vim.api.nvim_create_augroup('EnhancedNotifications', {
      clear = true,
    })

    -- File save notifications (optional, can be disabled if too noisy)
    vim.api.nvim_create_autocmd('BufWritePost', {
      group = notify_group,
      callback = function(args)
        -- Only notify for meaningful files (not temporary or special buffers)
        local bufname = vim.api.nvim_buf_get_name(args.buf)
        local buftype = vim.bo[args.buf].buftype

        if buftype == '' and bufname ~= '' and not bufname:match('^/tmp/') then notify_util.file_saved(bufname) end
      end,
    })

    -- Project change notifications
    vim.api.nvim_create_autocmd('User', {
      pattern = 'ProjectChanged',
      group = notify_group,
      callback = function()
        local cwd = vim.fn.getcwd()
        local project_name = vim.fn.fnamemodify(cwd, ':t')

        -- Detect project type
        local project_type = 'default'
        if _G.ProjectSwitcher then
          local type_info = _G.ProjectSwitcher.detect_project_type(cwd)
          project_type = type_info.type
        end

        notify_util.project_switched(project_name, project_type)
      end,
    })

    -- DAP notifications
    vim.api.nvim_create_autocmd('User', {
      pattern = 'DapSessionStarted',
      group = notify_group,
      callback = function() notify_util.debug_started() end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'DapSessionStopped',
      group = notify_group,
      callback = function() notify_util.debug_stopped() end,
    })

    -- Commands
    vim.api.nvim_create_user_command('NotifyDismiss', notify_util.dismiss_all, {
      desc = 'Dismiss all notifications',
    })

    vim.api.nvim_create_user_command('NotifyHistory', notify_util.show_history, {
      desc = 'Show notification history',
    })

    -- Keymaps
    vim.keymap.set('n', '<leader>An', notify_util.dismiss_all, {
      desc = 'Dismiss Notifications',
    })

    vim.keymap.set('n', '<leader>Ah', notify_util.show_history, {
      desc = 'Notification History',
    })

    -- Integration with telescope for notification history
    pcall(require('telescope').load_extension, 'notify')
  end,
}
