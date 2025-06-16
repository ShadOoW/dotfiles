-- DAP UI configuration
return {
    'rcarriga/nvim-dap-ui',
    dependencies = {'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio'},
    config = function()
        local dap = require('dap')
        local dapui = require('dapui')

        dapui.setup({
            -- Modern IDE-like icons and styling
            icons = {
                expanded = '▾',
                collapsed = '▸',
                current_frame = '▶'
            },
            controls = {
                enabled = true,
                element = 'repl',
                icons = {
                    pause = '⏸',
                    play = '▶',
                    step_into = '⏬',
                    step_over = '⏭',
                    step_out = '⏫',
                    step_back = '⏪',
                    run_last = '🔄',
                    terminate = '⏹',
                    disconnect = '⏏'
                }
            },
            element_mappings = {
                -- Custom mappings for elements
                scopes = {
                    edit = 'e',
                    expand = {'<CR>', '<2-LeftMouse>'},
                    repl = 'r'
                },
                stacks = {
                    open = '<CR>'
                },
                watches = {
                    edit = 'e',
                    expand = {'<CR>', '<2-LeftMouse>'},
                    remove = 'd',
                    repl = 'r'
                },
                breakpoints = {
                    open = '<CR>',
                    toggle = 't'
                }
            },
            expand_lines = true,
            layouts = {{
                -- Right sidebar - Variables, Call Stack, Breakpoints, Watches
                elements = {{
                    id = 'scopes',
                    size = 0.35 -- Variables
                }, {
                    id = 'stacks',
                    size = 0.25 -- Call Stack
                }, {
                    id = 'breakpoints',
                    size = 0.20 -- Breakpoints
                }, {
                    id = 'watches',
                    size = 0.20 -- Watches
                }},
                size = 0.30, -- 30% of screen width
                position = 'right'
            }, {
                -- Bottom panel - Debug Console and REPL
                elements = {{
                    id = 'console',
                    size = 0.60 -- Debug Console (program output)
                }, {
                    id = 'repl',
                    size = 0.40 -- Debug REPL (interactive)
                }},
                size = 0.25, -- 25% of screen height
                position = 'bottom'
            }},
            floating = {
                max_height = 0.9,
                max_width = 0.9,
                border = 'rounded',
                mappings = {
                    close = {'q', '<Esc>'}
                }
            },
            windows = {
                indent = 1
            },
            render = {
                max_type_length = nil,
                max_value_lines = 100
            }
        })

        -- Auto open DAP UI
        dap.listeners.after.event_initialized['dapui_config'] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated['dapui_config'] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited['dapui_config'] = function()
            dapui.close()
        end
    end
}
