-- All user commands for Neovim configuration
-- Centralized command definitions
-- ===== Basic Quit Commands =====
-- :q = normal quit behavior (default)
-- :Q = split-preserving quit behavior
-- :Qa = quit all
vim.api.nvim_create_user_command('Qa', function() vim.cmd('qall') end, {
  desc = 'Quit all',
})

-- ===== Buffer Management Commands =====

-- Handle :bd command specifically to prevent split closure
vim.api.nvim_create_user_command('Bd', function(opts)
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  -- Check if there are multiple windows
  if #vim.api.nvim_list_wins() > 1 then
    -- Create a new empty buffer first
    local new_buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_win_set_buf(win, new_buf)
    -- Make the buffer read-only and non-modifiable
    vim.bo[new_buf].readonly = true
    vim.bo[new_buf].modifiable = false
    vim.bo[new_buf].buftype = 'nofile'
  end

  -- Now safely delete the original buffer
  if opts.bang then
    vim.cmd('bdelete! ' .. buf)
  else
    vim.cmd('bdelete ' .. buf)
  end
end, {
  bang = true,
  desc = 'Delete buffer without closing split',
})

-- Handle :Q command specifically to prevent split closure
vim.api.nvim_create_user_command('Q', function(opts)
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)

  -- Check if buffer has unsaved changes and no bang
  if vim.bo[buf].modified and not opts.bang then
    vim.notify('No write since last change (add ! to override)', vim.log.levels.ERROR)
    return
  end

  -- If there are multiple windows, don't close the window, just switch to empty buffer
  if #vim.api.nvim_list_wins() > 1 then
    local new_buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_win_set_buf(win, new_buf)
    -- Make the buffer read-only and non-modifiable
    vim.bo[new_buf].readonly = true
    vim.bo[new_buf].modifiable = false
    vim.bo[new_buf].buftype = 'nofile'
    -- Only delete the original buffer if it's not the only buffer
    local buffers = vim.tbl_filter(
      function(b) return vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buftype == '' end,
      vim.api.nvim_list_bufs()
    )

    if #buffers > 1 then
      if opts.bang then
        vim.cmd('bdelete! ' .. buf)
      else
        pcall(vim.cmd, 'bdelete ' .. buf)
      end
    end
  else
    -- If only one window, use normal quit behavior
    if opts.bang then
      vim.cmd('quit!')
    else
      vim.cmd('quit')
    end
  end
end, {
  bang = true,
  desc = 'Quit without closing split',
})

-- ===== Tmux Integration Commands =====

vim.api.nvim_create_user_command('TmuxNewWindow', function(opts)
  local tmux = require('utils.tmux')
  tmux.new_window(opts.args)
end, {
  nargs = '?',
  desc = 'Create new tmux window',
})

vim.api.nvim_create_user_command('TmuxSplitH', function(opts)
  local tmux = require('utils.tmux')
  tmux.split_pane('horizontal', opts.args)
end, {
  nargs = '?',
  desc = 'Split tmux pane horizontally',
})

vim.api.nvim_create_user_command('TmuxSplitV', function(opts)
  local tmux = require('utils.tmux')
  tmux.split_pane('vertical', opts.args)
end, {
  nargs = '?',
  desc = 'Split tmux pane vertically',
})

vim.api.nvim_create_user_command('TmuxPanes', function()
  local tmux = require('utils.tmux')
  local panes = tmux.get_nvim_panes()
  if #panes == 0 then
    vim.notify('No other nvim instances found in this tmux session', vim.log.levels.INFO)
  else
    vim.notify('Found ' .. #panes .. ' nvim instances in this session', vim.log.levels.INFO)
    for i, pane in ipairs(panes) do
      print(i .. ': ' .. pane.id .. ' - ' .. pane.command)
    end
  end
end, {
  desc = 'List nvim panes in current tmux session',
})

-- ===== Configuration Management Commands =====

vim.api.nvim_create_user_command('ConfigReload', function() require('utils.reload').reload_config() end, {
  desc = 'Reload Neovim configuration',
})

-- ===== Java/JDTLS Commands =====

vim.api.nvim_create_user_command('JdtlsRestart', function()
  local clients = vim.lsp.get_active_clients()
  for _, client in ipairs(clients) do
    if client.name == 'jdtls' then
      vim.lsp.stop_client(client.id)
      vim.defer_fn(function() vim.cmd('LspStart jdtls') end, 1000)
      return
    end
  end
  vim.notify('JDTLS client not found', vim.log.levels.WARN)
end, {
  desc = 'Restart JDTLS language server',
})

vim.api.nvim_create_user_command('JdtlsCleanWorkspace', function()
  local workspace_path = vim.fn.expand('~/.cache/jdtls-workspace')
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
  local workspace_dir = workspace_path .. '/' .. project_name

  if vim.fn.isdirectory(workspace_dir) == 1 then
    vim.fn.delete(workspace_dir, 'rf')
    vim.notify('Cleaned JDTLS workspace: ' .. workspace_dir, vim.log.levels.INFO)
    vim.cmd('JdtlsRestart')
  else
    vim.notify('Workspace directory not found: ' .. workspace_dir, vim.log.levels.WARN)
  end
end, {
  desc = 'Clean JDTLS workspace and restart',
})

vim.api.nvim_create_user_command('JdtlsCheckJava', function()
  local java_version = vim.fn.system('java -version 2>&1 | head -1')
  local java_home = vim.env.JAVA_HOME or 'Not set'
  local jdtls_root = vim.fn.expand('~/.local/share/nvim/mason/packages/jdtls')

  vim.notify('Java Version: ' .. java_version:gsub('\n', ''), vim.log.levels.INFO)
  vim.notify('JAVA_HOME: ' .. java_home, vim.log.levels.INFO)
  vim.notify('JDTLS Root: ' .. jdtls_root, vim.log.levels.INFO)

  if vim.fn.isdirectory(jdtls_root) == 1 then
    vim.notify('JDTLS installation found', vim.log.levels.INFO)
  else
    vim.notify('JDTLS installation not found', vim.log.levels.ERROR)
  end
end, {
  desc = 'Check Java and JDTLS setup',
})

vim.api.nvim_create_user_command('JdtlsStatus', function()
  local clients = vim.lsp.get_active_clients()
  local jdtls_client = nil
  for _, client in ipairs(clients) do
    if client.name == 'jdtls' then
      jdtls_client = client
      break
    end
  end

  if jdtls_client then
    vim.notify('JDTLS Status: Active (ID: ' .. jdtls_client.id .. ')', vim.log.levels.INFO)
    vim.notify('Root Dir: ' .. (jdtls_client.config.root_dir or 'Unknown'), vim.log.levels.INFO)
  else
    vim.notify('JDTLS Status: Not running', vim.log.levels.WARN)
  end
end, {
  desc = 'Show JDTLS status',
})

vim.api.nvim_create_user_command('JdtlsDebugRoot', function()
  local root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' })
  vim.notify('Detected root directory: ' .. (root_dir or 'Not found'), vim.log.levels.INFO)
end, {
  desc = 'Debug JDTLS root directory detection',
})
