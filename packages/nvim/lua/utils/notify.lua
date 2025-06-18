-- Simple notification utilities that work with Noice
-- Just forwards to vim.notify which Noice will handle
local M = {}

-- Simple forwarding functions for backwards compatibility
function M.info(title, msg, opts)
  opts = opts or {}
  opts.title = title
  vim.notify(msg, vim.log.levels.INFO, opts)
end

function M.warn(title, msg, opts)
  opts = opts or {}
  opts.title = title
  vim.notify(msg, vim.log.levels.WARN, opts)
end

function M.error(title, msg, opts)
  opts = opts or {}
  opts.title = title
  vim.notify(msg, vim.log.levels.ERROR, opts)
end

function M.success(title, msg, opts)
  opts = opts or {}
  opts.title = title
  vim.notify(msg, vim.log.levels.INFO, opts)
end

function M.debug(msg, opts) vim.notify(msg, vim.log.levels.DEBUG, opts) end

return M
