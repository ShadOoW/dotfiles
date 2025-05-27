-- Configuration reload utility
local M =
	{}

-- List of modules to reload
local modules_to_reload =
	{
		"config.options",
		"config.autocmds",
		"config.commands",
		"config.keymaps",
		"utils.keymap",
		"utils.file",
		"utils.string",
		"lsp.handlers",
		"plugins",
	}

-- Clear module from package.loaded cache
local function unload_module(
	module_name
)
	package.loaded[module_name] =
		nil

	-- Also unload submodules
	for
		loaded_module,
		_
	in
		pairs(
			package.loaded
		)
	do
		if
			loaded_module:match(
				"^"
					.. module_name
					.. "%."
			)
		then
			package.loaded[loaded_module] =
				nil
		end
	end
end

-- Reload all config modules
function M.reload_config()
	-- Unload all modules
	for
		_,
		module
	in
		ipairs(
			modules_to_reload
		)
	do
		unload_module(
			module
		)
	end

	-- Reload main modules
	require(
		"config.options"
	)
	require(
		"config.autocmds"
	)
	require(
		"config.commands"
	)
	require(
		"config.keymaps"
	)

	-- Reload utility modules
	require(
		"utils.keymap"
	)
	require(
		"utils.file"
	)
	require(
		"utils.string"
	)

	-- Print success message
	vim.notify(
		"Configuration reloaded successfully!",
		vim.log.levels.INFO
	)

	return true
end

-- Setup the reload command
function M.setup()
	vim.api.nvim_create_user_command(
		"ConfigReload",
		function()
			M.reload_config()
		end,
		{
			desc = "Reload Neovim configuration",
		}
	)
end

return M
