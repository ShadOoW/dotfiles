-- Telescope-tabs integration
return {
	"LukasPietzschmann/telescope-tabs",
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require(
			"telescope"
		).load_extension(
			"telescope-tabs"
		)

		-- Add keymaps for telescope-tabs
		vim.keymap.set(
			"n",
			"<leader>tt",
			"<cmd>Telescope telescope-tabs list_tabs<CR>",
			{
				desc = "List and search tabs",
			}
		)
	end,
}
