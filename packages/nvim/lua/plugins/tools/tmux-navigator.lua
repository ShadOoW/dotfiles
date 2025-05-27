-- Seamless navigation between tmux panes and vim splits
return {
	"christoomey/vim-tmux-navigator",
	lazy = false, -- We want this plugin to load immediately
	config = function()
		-- Disable default mappings if you want to customize them
		vim.g.tmux_navigator_no_mappings =
			0

		-- The plugin automatically sets up these keybindings:
		-- <ctrl-h> => Left
		-- <ctrl-j> => Down
		-- <ctrl-k> => Up
		-- <ctrl-l> => Right
		-- <ctrl-\> => Previous split
	end,
}
