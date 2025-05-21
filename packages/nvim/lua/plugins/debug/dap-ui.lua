-- DAP UI configuration
return {
    "rcarriga/nvim-dap-ui",
    dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
    keys = {{
        '<leader>b',
        function()
            require('dap').toggle_breakpoint()
        end,
        desc = 'Debug: Toggle Breakpoint'
    }, {
        '<leader>B',
        function()
            require('dap').set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = 'Debug: Set Breakpoint'
    }, {
        '<leader>lp',
        function()
            require('dap').set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
        end,
        desc = 'Debug: Set Log Point'
    }, {
        '<F7>',
        function()
            require('dapui').toggle()
        end,
        desc = 'Debug: Toggle UI'
    }, {
        '<leader>dr',
        function()
            require('dap').repl.open()
        end,
        desc = 'Debug: Open REPL'
    }, {
        '<leader>dl',
        function()
            require('dap').run_last()
        end,
        desc = 'Debug: Run Last'
    }},
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        dapui.setup({
            -- Set icons to characters that are more likely to work in every terminal
            icons = {
                expanded = '▾',
                collapsed = '▸',
                current_frame = '*'
            },
            controls = {
                icons = {
                    pause = '⏸',
                    play = '▶',
                    step_into = '⏎',
                    step_over = '⏭',
                    step_out = '⏮',
                    step_back = 'b',
                    run_last = '▶▶',
                    terminate = '⏹',
                    disconnect = '⏏'
                }
            },
            layouts = {{
                elements = {{
                    id = "scopes",
                    size = 0.33
                }, {
                    id = "breakpoints",
                    size = 0.17
                }, {
                    id = "stacks",
                    size = 0.25
                }, {
                    id = "watches",
                    size = 0.25
                }},
                size = 0.33,
                position = "right"
            }, {
                elements = {{
                    id = "repl",
                    size = 0.45
                }, {
                    id = "console",
                    size = 0.55
                }},
                size = 0.27,
                position = "bottom"
            }}
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

        -- Additional DAP keymaps are defined in the keys table at the top
        vim.keymap.set("n", "<F5>", function()
            dap.continue()
        end)
        vim.keymap.set("n", "<F10>", function()
            dap.step_over()
        end)
        vim.keymap.set("n", "<F11>", function()
            dap.step_into()
        end)
        vim.keymap.set("n", "<F12>", function()
            dap.step_out()
        end)
    end
}
