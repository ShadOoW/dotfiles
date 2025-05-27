-- Keymap utility
-- lua/utils/keymap.lua
local M = {}

-- General purpose keymap wrapper
local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, {
    noremap = true,
    silent = true,
    desc = desc, -- shows up in `which-key` and for documentation
  })
end

-- Mode-specific helpers
M.n = function(lhs, rhs, desc) map('n', lhs, rhs, desc) end -- normal mode
M.i = function(lhs, rhs, desc) map('i', lhs, rhs, desc) end -- insert mode
M.v = function(lhs, rhs, desc) map('v', lhs, rhs, desc) end -- visual mode
M.t = function(lhs, rhs, desc) map('t', lhs, rhs, desc) end -- terminal mode
M.x = function(lhs, rhs, desc) map('x', lhs, rhs, desc) end -- visual block mode

return M
