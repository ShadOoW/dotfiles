-- Smart window management and resizing
return {
	"mrjones2014/smart-splits.nvim",
	config = function()
		local smart_splits = require("smart-splits")

		-- Setup smart-splits with minimal config to avoid nil comparison errors
		smart_splits.setup({
			-- Ignored filetypes (only while resizing)
			ignored_filetypes = { "nofile", "quickfix", "prompt" },
			-- Ignored buffer types (only while resizing)
			ignored_buftypes = { "NvimTree" },
			-- Default split direction
			default_amount = 3,
			-- Whether the cursor should follow the window when swapping
			cursor_follows_swapped_bufs = true,
			-- Multiplier to use for resizing
			resize_mode_multiplier = 5,
			-- Disable animation config to avoid nil comparison errors
			animate = false,
			-- Prevent swapping with neo-tree or other special windows
			at_edge = "wrap",
			-- Custom function to determine if a window should be included in the swapping
			disable_multiplexer_nav_when_zoomed = true,
		})

		-- Custom function to handle buffer swapping without duplicating Neotree
		local function safe_swap_buf_left()
			local current_win = vim.api.nvim_get_current_win()
			local current_buf = vim.api.nvim_get_current_buf()
			local current_buftype = vim.api.nvim_buf_get_option(current_buf, "filetype")

			-- Don't swap if current buffer is neo-tree
			if current_buftype == "neo-tree" then
				return
			end

			-- Get the window to the left
			vim.cmd("wincmd h")
			local left_win = vim.api.nvim_get_current_win()

			if left_win ~= current_win then
				local left_buf = vim.api.nvim_get_current_buf()
				local left_buftype = vim.api.nvim_buf_get_option(left_buf, "filetype")

				-- Go back to original window
				vim.api.nvim_set_current_win(current_win)

				-- Only swap if left window is not neo-tree
				if left_buftype ~= "neo-tree" then
					smart_splits.swap_buf_left()
				end
			else
				-- Go back to original window if no left window exists
				vim.api.nvim_set_current_win(current_win)
			end
		end

		local function safe_swap_buf_right()
			local current_win = vim.api.nvim_get_current_win()
			local current_buf = vim.api.nvim_get_current_buf()
			local current_buftype = vim.api.nvim_buf_get_option(current_buf, "filetype")

			-- Don't swap if current buffer is neo-tree
			if current_buftype == "neo-tree" then
				return
			end

			-- Get the window to the right
			vim.cmd("wincmd l")
			local right_win = vim.api.nvim_get_current_win()

			if right_win ~= current_win then
				local right_buf = vim.api.nvim_get_current_buf()
				local right_buftype = vim.api.nvim_buf_get_option(right_buf, "filetype")

				-- Go back to original window
				vim.api.nvim_set_current_win(current_win)

				-- Only swap if right window is not neo-tree
				if right_buftype ~= "neo-tree" then
					smart_splits.swap_buf_right()
				end
			else
				-- Go back to original window if no right window exists
				vim.api.nvim_set_current_win(current_win)
			end
		end

		-- Fix the resizing shortcuts (left and right were reversed)
		vim.keymap.set("n", "<C-Left>", function()
			smart_splits.resize_left()
		end, {
			desc = "Increase window width",
		})

		vim.keymap.set("n", "<C-Right>", function()
			smart_splits.resize_right()
		end, {
			desc = "Decrease window width",
		})

		vim.keymap.set("n", "<C-Up>", function()
			smart_splits.resize_up()
		end, {
			desc = "Decrease window height",
		})

		vim.keymap.set("n", "<C-Down>", function()
			smart_splits.resize_down()
		end, {
			desc = "Increase window height",
		})

		-- Window management keymaps
		vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<CR>", {
			desc = "Split window vertically",
		})

		vim.keymap.set("n", "<leader>ws", "<cmd>split<CR>", {
			desc = "Split window horizontally",
		})

		vim.keymap.set("n", "<leader>wq", "<cmd>close<CR>", {
			desc = "Close window",
		})

		-- Swapping buffers between windows (using our safe swap functions)
		vim.keymap.set("n", "<leader>w<Left>", function()
			safe_swap_buf_left()
		end, {
			desc = "Swap with left buffer",
		})

		vim.keymap.set("n", "<leader>w<Down>", function()
			smart_splits.swap_buf_down()
		end, {
			desc = "Swap with down buffer",
		})

		vim.keymap.set("n", "<leader>w<Up>", function()
			smart_splits.swap_buf_up()
		end, {
			desc = "Swap with up buffer",
		})

		vim.keymap.set("n", "<leader>w<Right>", function()
			safe_swap_buf_right()
		end, {
			desc = "Swap with right buffer",
		})
	end,
}
