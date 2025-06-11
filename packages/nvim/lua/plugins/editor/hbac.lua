-- Healthy Buffer Auto-Close (HBAC)
-- Automatically close unmodified buffers when the number gets too high
return {
	"axkirillov/hbac.nvim",
	event = "VeryLazy",
	config = function()
		local hbac = require("hbac")

		-- Track buffers that have been modified
		local never_modified_buffers = {}

		-- Mark buffer as modified when entering insert mode or making changes
		local function track_buffer_modification()
			local bufnr = vim.api.nvim_get_current_buf()
			never_modified_buffers[bufnr] = false
		end

		-- Initialize tracking for new buffers
		vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
			callback = function(args)
				local bufnr = args.buf
				if never_modified_buffers[bufnr] == nil then
					never_modified_buffers[bufnr] = true -- Mark as never modified initially
				end
			end,
			desc = "Initialize buffer modification tracking",
		})

		-- Track when buffers are modified
		vim.api.nvim_create_autocmd({ "InsertEnter", "TextChanged", "TextChangedI" }, {
			callback = track_buffer_modification,
			desc = "Track buffer modifications for HBAC",
		})

		-- Clean up tracking when buffers are deleted
		vim.api.nvim_create_autocmd("BufDelete", {
			callback = function(args)
				never_modified_buffers[args.buf] = nil
			end,
			desc = "Clean up buffer modification tracking",
		})

		hbac.setup({
			-- Close buffers that haven't been viewed for this amount of time (in minutes)
			autoclose_if_unused_for = 30,

			-- Maximum number of unmodified buffers to keep
			threshold = 5,

			-- Never close these filetypes
			close_buffers_with_windows = false,

			-- Filetypes to ignore
			ignore_filetypes = {
				"help",
				"Trouble",
				"dashboard",
				"toggleterm",
				"DiffviewFiles",
				"DiffviewFileHistory",
				"qf",
				"TelescopePrompt",
				"TelescopeResults",
			},

			-- Buffer types to ignore
			ignore_buftypes = { "help", "nofile", "quickfix", "terminal", "prompt" },

			-- Custom close command that respects our never-modified tracking
			close_command = function(bufnr)
				-- Only close if buffer was never modified
				if never_modified_buffers[bufnr] == true then
					vim.api.nvim_buf_delete(bufnr, {})
				end
			end,
		})

		-- Add mappings for hbac
		vim.keymap.set("n", "<leader>fW", function()
			hbac.close_unpinned()
		end, {
			desc = "Close all unpinned buffers",
		})
		vim.keymap.set("n", "<leader>fp", function()
			hbac.toggle_pin()
		end, {
			desc = "Toggle pin buffer",
		})
		vim.keymap.set("n", "<leader>fP", function()
			-- Show buffer status info
			local buffers = vim.api.nvim_list_bufs()
			local pinned_count = 0
			local unpinned_count = 0
			local never_modified_count = 0
			local state = require("hbac.state")

			print("HBAC Buffer Status:")
			for _, bufnr in ipairs(buffers) do
				if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_option(bufnr, "buflisted") then
					local name = vim.api.nvim_buf_get_name(bufnr) or "[No Name]"
					local is_pinned = state.is_pinned(bufnr)
					local is_never_modified = never_modified_buffers[bufnr] == true

					local pin_status = is_pinned and "📍 PINNED" or "   unpinned"
					local mod_status = is_never_modified and "(never modified)" or "(was modified)"

					print(string.format("%s %s: %s", pin_status, mod_status, vim.fn.fnamemodify(name, ":t")))

					if is_pinned then
						pinned_count = pinned_count + 1
					else
						unpinned_count = unpinned_count + 1
					end

					if is_never_modified then
						never_modified_count = never_modified_count + 1
					end
				end
			end
			print(
				string.format(
					"Total: %d pinned, %d unpinned, %d never modified",
					pinned_count,
					unpinned_count,
					never_modified_count
				)
			)
		end, {
			desc = "Show HBAC buffer status",
		})
	end,
}
