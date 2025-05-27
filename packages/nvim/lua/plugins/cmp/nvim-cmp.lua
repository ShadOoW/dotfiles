-- Completion setup with nvim-cmp
return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
	},
	event = "InsertEnter",
	config = function()
		local cmp =
			require(
				"cmp"
			)
		cmp.setup({
			mapping = cmp.mapping.preset.insert(),
			sources = {
				{
					name = "nvim_lsp",
				},
				{
					name = "buffer",
				},
				{
					name = "path",
				},
			},
		})
	end,
}
