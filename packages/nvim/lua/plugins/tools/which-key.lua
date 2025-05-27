return {
	"folke/which-key.nvim",
	event = "VimEnter",
	opts = {
		delay = 0,
		icons = {
			mappings = vim.g.have_nerd_font,
			keys = vim.g.have_nerd_font
					and {}
				or {
					Up = "<Up> ",
					Down = "<Down> ",
					Left = "<Left> ",
					Right = "<Right> ",
					-- Add more key mappings as needed
				},
		},
		spec = {
			{
				"<leader>w",
				group = "Window",
			},
			{
				"<leader>f",
				group = "File",
			},
			{
				"<leader>s",
				group = "Search",
			},
			{
				"<leader>t",
				group = "Toggle",
			},
			{
				"<leader>a",
				group = "Actions",
			},
			{
				"<leader>h",
				group = "Git [H]unk",
				mode = {
					"n",
					"v",
				},
			},
		},
	},
}
