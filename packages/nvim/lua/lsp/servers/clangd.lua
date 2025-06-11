-- Clangd LSP server configuration
return {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--function-arg-placeholders",
		"--fallback-style=llvm",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
	root_dir = function(fname)
		return require("lspconfig.util").root_pattern(
			".clangd",
			".clang-tidy",
			".clang-format",
			"compile_commands.json",
			"compile_flags.txt",
			"configure.ac",
			".git"
		)(fname)
	end,
	single_file_support = true,
}
