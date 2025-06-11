-- JSON LSP server configuration
return {
	settings = {
		json = {
			schemas = (function()
				local ok, schemastore = pcall(require, "schemastore")
				if ok then
					return schemastore.json.schemas()
				end
				return {}
			end)(),
			validate = {
				enable = true,
			},
		},
	},
	filetypes = { "json", "jsonc" },
	single_file_support = true,
}
