-- Plugin configuration file
-- This file imports plugins from each category folder
-- Each folder should have its own init.lua that exports the plugins in that category
-- Import and combine all plugin specifications from subdirectories
return { -- Each require returns a table of plugin specs
	require("plugins.ui"),
	require("plugins.lsp"),
	require("plugins.cmp"),
	require("plugins.ai"),
	require("plugins.tools"),
	require("plugins.git"),
	require("plugins.editor"),
	require("plugins.debug"),
}
