-- Main Neovim configuration entry point
-- This file delegates all configuration to modules in lua/
-- Add the lua directory to the runtime path
vim.opt.rtp:append(
	vim.fn.stdpath(
		"config"
	)
		.. "/lua"
)

-- Load the main lua/init.lua module (if it has other setup)
require(
	"init"
)
