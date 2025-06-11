-- Deno LSP server configuration
return {
	settings = {
		deno = {
			enable = true,
			lint = true,
			unstable = true,
		},
	},
	filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
	root_dir = function(fname)
		return require("lspconfig.util").root_pattern("deno.json", "deno.jsonc", "deps.ts", "import_map.json")(fname)
	end,
	single_file_support = false, -- Disable for Deno to avoid conflicts with ts_ls
}
