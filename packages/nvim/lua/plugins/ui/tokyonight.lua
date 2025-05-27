return {
	"folke/tokyonight.nvim",
	priority = 1000, -- Load before other start plugins
	config = function()
		require(
			"tokyonight"
		).setup({
			styles = {
				comments = {
					italic = false,
				}, -- Disable italics in comments
			},
		})
		vim.cmd.colorscheme("tokyonight-night")
	end,
}
