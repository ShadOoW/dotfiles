-- Docker LSP server configuration
return {
	filetypes = { "dockerfile" },
	root_dir = function(fname)
		return require("lspconfig.util").root_pattern("Dockerfile", ".git")(fname)
	end,
	single_file_support = true,
}
