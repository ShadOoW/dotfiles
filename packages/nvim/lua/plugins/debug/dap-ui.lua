-- DAP UI configuration
return {
	"rcarriga/nvim-dap-ui",
	dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		dapui.setup({
			-- Set icons to characters that are more likely to work in every terminal
			icons = {
				expanded = "▾",
				collapsed = "▸",
				current_frame = "*",
			},
			controls = {
				icons = {
					pause = "⏸",
					play = "▶",
					step_into = "⏎",
					step_over = "⏭",
					step_out = "⏮",
					step_back = "b",
					run_last = "▶▶",
					terminate = "⏹",
					disconnect = "⏏",
				},
			},
			layouts = {
				{
					elements = {
						{
							id = "scopes",
							size = 0.33,
						},
						{
							id = "breakpoints",
							size = 0.17,
						},
						{
							id = "stacks",
							size = 0.25,
						},
						{
							id = "watches",
							size = 0.25,
						},
					},
					size = 0.33,
					position = "right",
				},
				{
					elements = {
						{
							id = "repl",
							size = 0.45,
						},
						{
							id = "console",
							size = 0.55,
						},
					},
					size = 0.27,
					position = "bottom",
				},
			},
		})

		-- Auto open DAP UI
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end
	end,
}
