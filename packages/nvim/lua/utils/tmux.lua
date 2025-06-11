-- Tmux integration utilities
local M = {}

-- Check if we're running inside tmux
function M.is_tmux() return vim.env.TMUX ~= nil end

-- Get current tmux session name
function M.get_session_name()
  if not M.is_tmux() then return nil end

  local handle = io.popen('tmux display-message -p "#S" 2>/dev/null')
  if handle then
    local session_name = handle:read('*a'):gsub('\n', '')
    handle:close()
    return session_name ~= '' and session_name or nil
  end
  return nil
end

-- Get current tmux window name
function M.get_window_name()
  if not M.is_tmux() then return nil end

  local handle = io.popen('tmux display-message -p "#W" 2>/dev/null')
  if handle then
    local window_name = handle:read('*a'):gsub('\n', '')
    handle:close()
    return window_name ~= '' and window_name or nil
  end
  return nil
end

-- Set tmux window title
function M.set_window_title(title)
  if not M.is_tmux() or not title then return false end

  local escaped_title = title:gsub([["]], [[\"]])
  local success = os.execute('tmux rename-window "' .. escaped_title .. '" 2>/dev/null')
  return success == 0
end

-- Get current tmux pane index
function M.get_pane_index()
  if not M.is_tmux() then return nil end

  local handle = io.popen('tmux display-message -p "#P" 2>/dev/null')
  if handle then
    local pane_index = handle:read('*a'):gsub('\n', '')
    handle:close()
    return tonumber(pane_index)
  end
  return nil
end

-- Check if current pane is zoomed
function M.is_zoomed()
  if not M.is_tmux() then return false end

  local handle = io.popen('tmux display-message -p "#{window_zoomed_flag}" 2>/dev/null')
  if handle then
    local zoomed = handle:read('*a'):gsub('\n', '')
    handle:close()
    return zoomed == '1'
  end
  return false
end

-- Send keys to tmux
function M.send_keys(keys)
  if not M.is_tmux() or not keys then return false end

  local success = os.execute('tmux send-keys "' .. keys .. '" 2>/dev/null')
  return success == 0
end

-- Create a new tmux window with specific command
function M.new_window(name, command)
  if not M.is_tmux() then return false end

  local cmd = 'tmux new-window'
  if name then cmd = cmd .. ' -n "' .. name .. '"' end
  if command then cmd = cmd .. ' "' .. command .. '"' end

  local success = os.execute(cmd .. ' 2>/dev/null')
  return success == 0
end

-- Split current pane
function M.split_pane(direction, command)
  if not M.is_tmux() then return false end

  local flag = direction == 'horizontal' and '-h' or '-v'
  local cmd = 'tmux split-window ' .. flag

  if command then cmd = cmd .. ' "' .. command .. '"' end

  local success = os.execute(cmd .. ' 2>/dev/null')
  return success == 0
end

-- Get list of nvim instances in current tmux session
function M.get_nvim_panes()
  if not M.is_tmux() then return {} end

  local handle = io.popen('tmux list-panes -s -F "#{pane_id} #{pane_current_command}" 2>/dev/null')
  local panes = {}

  if handle then
    for line in handle:lines() do
      local pane_id, command = line:match('(%S+) (.+)')
      if command and command:match('n?vim') then
        table.insert(panes, {
          id = pane_id,
          command = command,
        })
      end
    end
    handle:close()
  end

  return panes
end

-- Switch to specific tmux pane
function M.switch_to_pane(pane_id)
  if not M.is_tmux() or not pane_id then return false end

  local success = os.execute('tmux select-pane -t "' .. pane_id .. '" 2>/dev/null')
  return success == 0
end

-- Refresh tmux client
function M.refresh_client()
  if not M.is_tmux() then return false end

  local success = os.execute('tmux refresh-client -S 2>/dev/null')
  return success == 0
end

-- Get project-specific session name
function M.get_project_session_name()
  local cwd = vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(cwd, ':t')

  -- If in a git repo, use the repo name
  if vim.fn.isdirectory('.git') == 1 then
    local git_handle = io.popen('git rev-parse --show-toplevel 2>/dev/null')
    if git_handle then
      local git_root = git_handle:read('*a'):gsub('\n', '')
      git_handle:close()
      if git_root ~= '' then project_name = vim.fn.fnamemodify(git_root, ':t') end
    end
  end

  return project_name
end

-- Setup project-based tmux workflow
function M.setup_project_workflow()
  if not M.is_tmux() then return end

  local project_name = M.get_project_session_name()
  local current_session = M.get_session_name()

  -- If not in a project session, create or switch to one
  if current_session ~= project_name then
    -- Check if session exists
    local handle = io.popen('tmux has-session -t "' .. project_name .. '" 2>/dev/null; echo $?')
    if handle then
      local exit_code = handle:read('*a'):gsub('\n', '')
      handle:close()

      if exit_code == '0' then
        -- Session exists, switch to it
        os.execute('tmux switch-client -t "' .. project_name .. '" 2>/dev/null')
      else
        -- Create new session
        os.execute('tmux new-session -d -s "' .. project_name .. '" 2>/dev/null')
        os.execute('tmux switch-client -t "' .. project_name .. '" 2>/dev/null')
      end
    end
  end
end

-- Enhanced focus detection for multiple nvim instances
function M.handle_focus_gained()
  if not M.is_tmux() then return end

  -- Don't run in command-line window
  if vim.fn.getcmdwintype() ~= '' then return end

  -- Refresh tmux client
  M.refresh_client()

  -- Check if this is the active pane
  local current_pane = M.get_pane_index()
  local handle = io.popen('tmux display-message -p "#{pane_active}" 2>/dev/null')
  if handle then
    local is_active = handle:read('*a'):gsub('\n', '')
    handle:close()

    if is_active == '1' then
      -- This pane is active, check for file changes safely
      local ok, _ = pcall(vim.cmd, 'checktime')
      if not ok then
        -- If checktime fails, schedule it for later
        vim.schedule(function()
          if vim.fn.getcmdwintype() == '' then vim.cmd('checktime') end
        end)
      end
    end
  end
end

-- Setup tmux integration
function M.setup()
  if not M.is_tmux() then return end

  -- Create autocmds for tmux integration
  local group = vim.api.nvim_create_augroup('tmux-integration', {
    clear = true,
  })

  -- Handle focus events
  vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
    group = group,
    callback = M.handle_focus_gained,
  })

  -- Setup project workflow on VimEnter
  vim.api.nvim_create_autocmd('VimEnter', {
    group = group,
    once = true,
    callback = M.setup_project_workflow,
  })

  -- Note: Tmux user commands are now defined in commands.lua
end

return M
