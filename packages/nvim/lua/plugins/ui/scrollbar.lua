-- Enhanced scrollbar with comprehensive hints and Tokyo Night theme integration
return {
    'petertriho/nvim-scrollbar',
    dependencies = {'lewis6991/gitsigns.nvim', -- For enhanced git integration
    'kevinhwang91/nvim-hlslens' -- For enhanced search integration
    },
    event = 'VeryLazy',
    config = function()
        local scrollbar = require('scrollbar')
        local colors = {
            bg = '#16161e', -- Darker background for better contrast
            bg_highlight = '#1a1b26', -- Tokyo Night background for handle
            fg = '#c0caf5', -- Tokyo Night foreground
            handle = '#3b4261', -- Subtle handle color that won't interfere with marks
            handle_hover = '#7aa2f7', -- Brighter handle color on hover
            cursor = '#7aa2f7', -- Tokyo Night blue
            search = '#ff9e64', -- Tokyo Night orange
            error = '#f7768e', -- Tokyo Night red
            warn = '#e0af68', -- Tokyo Night yellow
            info = '#7dcfff', -- Tokyo Night cyan
            hint = '#1abc9c', -- Tokyo Night teal
            misc = '#bb9af7', -- Tokyo Night purple
            git_add = '#9ece6a', -- Tokyo Night green
            git_change = '#7aa2f7', -- Tokyo Night blue
            git_delete = '#f7768e' -- Tokyo Night red
        }

        -- Custom highlight groups for better visibility
        vim.api.nvim_set_hl(0, 'ScrollbarHandle', {
            fg = colors.handle,
            bg = colors.bg_highlight,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'ScrollbarHandleHover', {
            fg = colors.handle_hover,
            bg = colors.bg_highlight,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'ScrollbarCursor', {
            fg = colors.cursor,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'ScrollbarSearch', {
            fg = colors.search,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'ScrollbarError', {
            fg = colors.error,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'ScrollbarWarn', {
            fg = colors.warn,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'ScrollbarInfo', {
            fg = colors.info,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'ScrollbarHint', {
            fg = colors.hint,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'ScrollbarMisc', {
            fg = colors.misc,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'ScrollbarGitAdd', {
            fg = colors.git_add,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'ScrollbarGitChange', {
            fg = colors.git_change,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'ScrollbarGitDelete', {
            fg = colors.git_delete,
            bold = true
        })

        scrollbar.setup({
            show = true,
            show_in_active_only = false,
            set_highlights = false, -- We'll use our custom highlights
            folds = 1000, -- Handle folds, set to number to disable folds if no. of lines in buffer exceeds this
            max_lines = false, -- Disable if no. of lines in buffer exceeds this
            hide_if_all_visible = true, -- Hide if all lines are visible
            throttle_ms = 100,
            handle = {
                text = '│', -- Thinner handle that won't interfere with marks
                color = nil, -- Use highlight group instead
                blend = 0, -- No transparency for better visibility
                highlight = 'ScrollbarHandle',
                hide_if_all_visible = true,
                hover = {
                    text = '┃', -- Slightly thicker on hover but still thin
                    highlight = 'ScrollbarHandleHover'
                }
            },
            marks = {
                Cursor = {
                    text = '󰇀', -- Thicker cursor mark
                    priority = 0,
                    highlight = 'ScrollbarCursor'
                },
                Search = {
                    text = {'?', '?', '?'}, -- Graduated marks for better visibility
                    priority = 1,
                    highlight = 'ScrollbarSearch'
                },
                Error = {
                    text = {'E', 'E', 'E'}, -- Graduated marks for better visibility
                    priority = 2,
                    highlight = 'ScrollbarError'
                },
                Warn = {
                    text = {'W', 'W', 'W'}, -- Graduated marks for better visibility
                    priority = 3,
                    highlight = 'ScrollbarWarn'
                },
                Info = {
                    text = {'I', 'I', 'I'}, -- Graduated marks for better visibility
                    priority = 4,
                    highlight = 'ScrollbarInfo'
                },
                Hint = {
                    text = {'H', 'H', 'H'}, -- Graduated marks for better visibility
                    priority = 5,
                    highlight = 'ScrollbarHint'
                },
                Misc = {
                    text = {'*', '*', '*'}, -- Graduated marks for better visibility
                    priority = 6,
                    highlight = 'ScrollbarMisc'
                },
                GitAdd = {
                    text = '+', -- Thicker git marks
                    priority = 7,
                    highlight = 'ScrollbarGitAdd'
                },
                GitChange = {
                    text = '~', -- Thicker git marks
                    priority = 7,
                    highlight = 'ScrollbarGitChange'
                },
                GitDelete = {
                    text = '-', -- Thicker deletion mark
                    priority = 7,
                    highlight = 'ScrollbarGitDelete'
                }
            },
            excluded_buftypes = {'terminal', 'prompt', 'nofile'},
            excluded_filetypes = {'blink-cmp-menu', 'cmp_docs', 'cmp_menu', 'dropbar_menu', 'dropbar_menu_fzf',
                                  'dressing', 'DressingInput', 'DressingSelect', 'fugitive', 'help', 'lazy', 'lazyterm',
                                  'mason', 'noice', 'prompt', 'TelescopePrompt', 'TelescopeResults', 'toggleterm',
                                  'Trouble'},
            autocmd = {
                render = {'BufWinEnter', 'TabEnter', 'TermEnter', 'WinEnter', 'CmdwinLeave', 'TextChanged',
                          'VimResized', 'WinScrolled'},
                clear = {'BufWinLeave', 'TabLeave', 'TermLeave', 'WinLeave'}
            },
            handlers = {
                cursor = true,
                diagnostic = true,
                gitsigns = true, -- Enable git signs integration
                handle = true,
                search = true, -- Enable search integration with hlslens
                ale = false -- Disable ALE integration
            }
        })

        -- Set up search integration with hlslens
        require('scrollbar.handlers.search').setup({
            override_lens = function()
            end -- Disable virtual text from hlslens
        })

        -- Set up git signs integration
        require('scrollbar.handlers.gitsigns').setup()
    end
}
