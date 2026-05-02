local M = {}

local CACHE_BASE = vim.fn.expand('~/.cache/managed-nvim')

--- Returns a path for regenerable cache data, creating it if possible.
--- Attempts to use ~/.cache/managed-nvim/<subdir> (btrfs @home-cache subvolume).
--- Falls back to stdpath('data')/<subdir> if creation fails (e.g. macOS without ~/.cache).
---@param subdir string
---@return string
function M.cache_path(subdir)
  local full = CACHE_BASE .. '/' .. subdir
  vim.fn.mkdir(full, 'p')
  if vim.uv.fs_stat(full) then return full end
  local fallback = vim.fn.stdpath('data') .. '/' .. subdir
  vim.fn.mkdir(fallback, 'p')
  return fallback
end

return M
