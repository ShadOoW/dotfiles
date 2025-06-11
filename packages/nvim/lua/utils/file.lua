-- File utilities module
local M = {}

-- Check if file exists
M.file_exists = function(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

-- Get the size of a file
M.file_size = function(path)
	local f = io.open(path, "r")
	if f then
		local size = f:seek("end")
		f:close()
		return size
	end
	return 0
end

-- Read a file into a string
M.read_file = function(path)
	local f = io.open(path, "r")
	if f then
		local content = f:read("*all")
		f:close()
		return content
	end
	return nil
end

-- Write a string to a file
M.write_file = function(path, content)
	local f = io.open(path, "w")
	if f then
		f:write(content)
		f:close()
		return true
	end
	return false
end

-- Get the parent directory of a path
M.dirname = function(path)
	return path:match("(.*/)")
end

-- Extract the file name from a path
M.basename = function(path)
	return path:match("([^/]*)$")
end

-- Create a directory and any required parent directories
M.mkdir_p = function(path)
	-- Use Neovim's built-in fs_mkdir if available
	if vim.fn.has("nvim-0.5") == 1 then
		return vim.fn.mkdir(path, "p")
	else
		return vim.fn.mkdir(path, "p")
	end
end

return M
