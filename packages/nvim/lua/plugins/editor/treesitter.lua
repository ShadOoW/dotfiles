-- Treesitter configuration
return { -- Main treesitter plugin
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = {'BufReadPost', 'BufNewFile'},
    cmd = {'TSInstall', 'TSUpdate', 'TSModuleInfo', 'TSBufEnable', 'TSBufDisable', 'TSBufToggle', 'TSEnable',
           'TSDisable', 'TSToggle'},
    dependencies = { -- Show code context at the top of the window
    {
        'nvim-treesitter/nvim-treesitter-context',
        opts = {
            enable = true,
            max_lines = 3, -- How many lines the window should span
            min_window_height = 0, -- Minimum editor window height to enable context
            line_numbers = true,
            multiline_threshold = 20, -- Maximum number of lines to show for a multi-line context
            trim_scope = 'outer', -- Which scope to trim the context from
            mode = 'cursor', -- Line used to calculate context
            separator = nil, -- Separator between context and content
            zindex = 20, -- Z-index of the context window
            on_attach = nil -- Function called when attaching to a buffer
        }
    }},
    config = function()
        require('nvim-treesitter.configs').setup({
            -- Add languages to be installed here that you want installed for treesitter
            ensure_installed = {'bash', 'c', 'cpp', 'css', 'diff', 'go', 'html', 'javascript', 'json', 'lua', 'luadoc',
                                'luap', 'markdown', 'markdown_inline', 'python', 'query', 'regex', 'rust', 'tsx',
                                'typescript', 'vim', 'vimdoc', 'yaml'},

            -- Autoinstall languages that are not installed
            auto_install = true,

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = {'ruby'}
            },

            indent = {
                enable = true,
                disable = {'ruby'}
            },

            -- Optional features
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = '<C-space>',
                    node_incremental = '<C-space>',
                    scope_incremental = '<C-s>',
                    node_decremental = '<M-space>'
                }
            },

            textobjects = {
                select = {
                    enable = true,
                    lookahead = true, -- Automatically jump forward to textobj
                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ['aa'] = '@parameter.outer',
                        ['ia'] = '@parameter.inner',
                        ['af'] = '@function.outer',
                        ['if'] = '@function.inner',
                        ['ac'] = '@class.outer',
                        ['ic'] = '@class.inner'
                    }
                },
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        [']m'] = '@function.outer',
                        [']]'] = '@class.outer'
                    },
                    goto_next_end = {
                        [']M'] = '@function.outer',
                        [']['] = '@class.outer'
                    },
                    goto_previous_start = {
                        ['[m'] = '@function.outer',
                        ['[['] = '@class.outer'
                    },
                    goto_previous_end = {
                        ['[M'] = '@function.outer',
                        ['[]'] = '@class.outer'
                    }
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ['<leader>a'] = '@parameter.inner'
                    },
                    swap_previous = {
                        ['<leader>A'] = '@parameter.inner'
                    }
                }
            }
        })

        -- Diagnostic keymaps
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {
            desc = 'Go to previous diagnostic message'
        })
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {
            desc = 'Go to next diagnostic message'
        })
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {
            desc = 'Open floating diagnostic message'
        })
        vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, {
            desc = 'Open diagnostics list'
        })
    end
}
