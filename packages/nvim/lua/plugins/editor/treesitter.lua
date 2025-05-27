-- Treesitter configuration
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = "BufReadPost",
	opts = {
		ensure_installed = {
			"html",
			"css",
			"typescript",
			"tsx",
			"javascript",
			"astro",
		},
		auto_install = true,
		highlight = {
			enable = true,
		},
		indent = {
			enable = true,
		},
	},
	config = function(
		_,
		opts
	)
		require(
			"nvim-treesitter.configs"
		).setup(
			opts
		)
	end,
}
