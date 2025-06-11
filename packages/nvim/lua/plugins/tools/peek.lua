return {
	"toppair/peek.nvim",
	build = "deno task --quiet build:fast",
	cmd = {
		"PeekOpen",
		"PeekClose",
	},
	config = function()
		require("peek").setup({})
	end,
}
