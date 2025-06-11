-- Codeium AI completion - FREE with generous limits
return {
	"Exafunction/codeium.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
	event = "InsertEnter",
	build = ":Codeium Auth",
	config = function()
		require("codeium").setup({
			enable_cmp_source = false,
			virtual_text = {
				enabled = true,
				manual = false,
				default_filetype_enabled = true,
				idle_delay = 150,
				virtual_text_priority = 100,
				map_keys = true,
				key_bindings = {
					accept = "<Tab>",
					accept_word = "<C-w>",
					accept_line = "<C-l>",
					clear = "<C-BS>",
					next = "<M-]>",
					prev = "<M-[>",
				},
			},
		})

		-- NOTE: Tab is used for completion acceptance
		-- Tab: Accept completion
		-- Ctrl+W: Accept word
		-- Ctrl+L: Accept line
	end,
}
