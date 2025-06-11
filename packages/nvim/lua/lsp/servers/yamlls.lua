-- YAML LSP server configuration
return {
	settings = {
		yaml = {
			keyOrdering = false,
			format = {
				enable = true,
			},
			hover = true,
			completion = true,
			validate = true,
			schemas = (function()
				local ok, schemastore = pcall(require, "schemastore")
				if ok then
					return schemastore.yaml.schemas()
				end
				return {}
			end)(),
		},
	},
	filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
	single_file_support = true,
}
