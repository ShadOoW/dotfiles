-- Browser utility functions
-- Provides a unified interface for opening browsers with fallback support
local M = {}

-- Check if a command exists
local function command_exists(cmd)
  local handle = io.popen('which ' .. cmd .. ' 2>/dev/null')
  local result = handle and handle:read('*a'):gsub('%s+', '')
  if handle then handle:close() end
  return result and result ~= ''
end

-- Get the appropriate browser command with options
local function get_browser_cmd(url, opts)
  opts = opts or {}

  -- Try qutebrowser first
  if command_exists('qutebrowser') then
    local cmd = 'env QT_QPA_PLATFORM=xcb qutebrowser'
    if opts.target_window then cmd = cmd .. ' --target window' end
    if opts.window_name then cmd = cmd .. ' --qt-arg name ' .. opts.window_name end
    cmd = cmd .. ' ' .. url .. ' &'
    return cmd, 'qutebrowser'
  end

  -- Try chromium second
  if command_exists('chromium') then
    local cmd = 'chromium'
    if opts.minimal then
      cmd = cmd .. ' --app=' .. url
    else
      cmd = cmd .. ' --new-window ' .. url
    end
    cmd = cmd .. ' &'
    return cmd, 'chromium'
  end

  -- Try firefox as fallback
  if command_exists('firefox') then
    local cmd = 'firefox'
    if opts.minimal then
      -- Firefox doesn't have a direct --app equivalent, but we can use --new-window
      cmd = cmd .. ' --new-window ' .. url
    else
      cmd = cmd .. ' --new-window ' .. url
    end
    cmd = cmd .. ' &'
    return cmd, 'firefox'
  end

  return nil, nil
end

-- Open a URL in the best available browser
-- Options:
--   minimal: Use minimal/app mode if supported (chromium --app)
--   target_window: For qutebrowser, open in target window
--   window_name: For qutebrowser, set window name
function M.open_url(url, opts)
  opts = opts or {}

  local cmd, browser = get_browser_cmd(url, opts)

  if not cmd then
    vim.notify('No supported browser found (qutebrowser, chromium, firefox)', vim.log.levels.ERROR)
    return false
  end

  local success = os.execute(cmd)
  if success == 0 then
    local mode_text = opts.minimal and ' (minimal mode)' or ''
    vim.notify('Opened in ' .. browser .. mode_text, vim.log.levels.INFO)
    return true
  else
    vim.notify('Failed to open browser: ' .. browser, vim.log.levels.ERROR)
    return false
  end
end

-- Open markdown preview with specific settings
function M.open_markdown_preview(url)
  return M.open_url(url, {
    target_window = true,
    window_name = 'obsidian-browser',
    minimal = true,
  })
end

-- Open in minimal/app mode
function M.open_minimal(url)
  return M.open_url(url, {
    minimal = true,
  })
end

return M
