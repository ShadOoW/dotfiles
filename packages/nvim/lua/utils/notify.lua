-- Enhanced notification utilities with modern notification panel integration
-- Works seamlessly with both compact notifications and detailed panel viewing
local M = {}

-- Simple forwarding functions for backwards compatibility and enhanced functionality
function M.info(title, msg, opts)
  opts = opts or {}
  opts.title = title
  opts.original_msg = msg -- Preserve full message for panel viewing
  vim.notify(msg, vim.log.levels.INFO, opts)
end

function M.warn(title, msg, opts)
  opts = opts or {}
  opts.title = title
  opts.original_msg = msg
  vim.notify(msg, vim.log.levels.WARN, opts)
end

function M.error(title, msg, opts)
  opts = opts or {}
  opts.title = title
  opts.original_msg = msg
  vim.notify(msg, vim.log.levels.ERROR, opts)
end

function M.success(title, msg, opts)
  opts = opts or {}
  opts.title = title
  opts.original_msg = msg
  vim.notify(msg, vim.log.levels.INFO, opts)
end

function M.debug(msg, opts)
  opts = opts or {}
  opts.original_msg = msg
  vim.notify(msg, vim.log.levels.DEBUG, opts)
end

-- Enhanced functions for long messages that benefit from panel viewing
function M.long_info(title, msg, opts)
  opts = opts or {}
  opts.title = title
  opts.original_msg = msg
  -- Show brief notification but full message available in panel
  local brief = (#msg > 50) and (msg:sub(1, 47) .. '...') or msg
  vim.notify(brief, vim.log.levels.INFO, opts)
end

function M.long_error(title, msg, opts)
  opts = opts or {}
  opts.title = title
  opts.original_msg = msg
  local brief = (#msg > 50) and (msg:sub(1, 47) .. '...') or msg
  vim.notify(brief, vim.log.levels.ERROR, opts)
end

-- Quick access to notification panel
function M.show_panel()
  if _G.NotificationPanel then
    _G.NotificationPanel.open()
  else
    vim.notify('Notification panel not available', vim.log.levels.WARN)
  end
end

function M.get_stats()
  if _G.NotificationPanel then
    return {
      total = _G.NotificationPanel.get_count(),
      errors = _G.NotificationPanel.get_error_count(),
      warnings = _G.NotificationPanel.get_warning_count(),
    }
  end
  return {
    total = 0,
    errors = 0,
    warnings = 0,
  }
end

return M
