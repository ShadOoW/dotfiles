-- Simple notification utilities that work with Noice
-- Just forwards to vim.notify which Noice will handle
local M = {}

-- Simple forwarding functions for backwards compatibility
function M.info(msg, opts) vim.notify(msg, vim.log.levels.INFO, opts) end

function M.warn(msg, opts) vim.notify(msg, vim.log.levels.WARN, opts) end

function M.error(msg, opts) vim.notify(msg, vim.log.levels.ERROR, opts) end

function M.success(msg, opts)
  opts = opts or {}
  opts.title = '✅ Success'
  vim.notify(msg, vim.log.levels.INFO, opts)
end

function M.debug(msg, opts) vim.notify(msg, vim.log.levels.DEBUG, opts) end

-- Project switcher specific function
function M.project_switched(name, type)
  vim.notify('📂 Switched to ' .. name .. ' (' .. type .. ')', vim.log.levels.INFO, {
    title = 'Project Switcher',
  })
end

return M
