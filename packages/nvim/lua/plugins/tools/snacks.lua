-- Snacks.nvim plugins collection by folke
-- https://github.com/folke/snacks.nvim
return {
	{
		"folke/snacks.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
		config = function()
			local ok, snacks = pcall(require, "snacks")
			if not ok then
				return
			end
			snacks.setup({
				rename = {
					enable = true,
				},
				bufdelete = {
					enable = true,
				},
				image = {
					enable = false,
				},
				styles = {
					enable = true,
				},
				input = {
					enable = true,
				},
				layout = {
					enable = true,
				},
				notifier = {
					enable = true,
				},
				notify = {
					enable = true,
				},
				picker = {
					enable = true,
				},
				statuscolumn = {
					enable = true,
				},
				scroll = {
					enable = true,
				},
				terminal = {
					enable = true,
				},
				toggle = {
					enable = true,
				},
				util = {
					enable = true,
				},
				win = {
					enable = true,
				},
			})
		end,
	},
}
