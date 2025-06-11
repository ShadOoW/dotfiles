-- Astro LSP server configuration
return {
	filetypes = { "astro" },
	init_options = {
		typescript = {
			tsdk = vim.fn.stdpath("data") .. "/mason/packages/typescript-language-server/node_modules/typescript/lib",
		},
	},
	settings = {
		astro = {
			format = {
				indentFrontmatter = false,
			},
			typescript = {
				enabled = true,
			},
			preferences = {
				quotePreference = "single",
			},
		},
	},
	root_dir = function(fname)
		return require("lspconfig.util").root_pattern(
			"astro.config.mjs",
			"astro.config.js",
			"astro.config.ts",
			"package.json",
			".git"
		)(fname)
	end,
	single_file_support = true,
}
