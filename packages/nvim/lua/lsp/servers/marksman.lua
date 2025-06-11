-- Marksman (Markdown) LSP server configuration
return {
	filetypes = { "markdown", "markdown.mdx" },
	root_dir = function(fname)
		return require("lspconfig.util").root_pattern(".git", ".marksman.toml")(fname)
	end,
	single_file_support = true,
}
