-- String utilities module
local M = {}

-- Check if a string starts with a specified substring
M.starts_with = function(str, start) return str:sub(1, #start) == start end

-- Check if a string ends with a specified substring
M.ends_with = function(str, ending) return ending == '' or str:sub(-#ending) == ending end

-- Split a string using a delimiter
M.split = function(str, delimiter)
  local result = {}
  local pattern = '(.-)' .. delimiter .. '()'
  local last_pos = 1
  local found, end_pos, match

  for match, end_pos in string.gmatch(str, pattern) do
    table.insert(result, match)
    last_pos = end_pos
  end

  if last_pos <= #str then table.insert(result, string.sub(str, last_pos)) end

  return result
end

-- Trim whitespace from the beginning and end of a string
M.trim = function(str) return str:match('^%s*(.-)%s*$') end

-- Get a substring of a string
M.substring = function(str, start_idx, end_idx)
  end_idx = end_idx or #str
  return string.sub(str, start_idx, end_idx)
end

-- Replace all occurrences of a pattern in a string
M.replace = function(str, pattern, replacement) return string.gsub(str, pattern, replacement) end

-- Convert a string to uppercase
M.to_upper = function(str) return string.upper(str) end

-- Convert a string to lowercase
M.to_lower = function(str) return string.lower(str) end

-- Check if a string contains a substring
M.contains = function(str, substr) return string.find(str, substr, 1, true) ~= nil end

return M
