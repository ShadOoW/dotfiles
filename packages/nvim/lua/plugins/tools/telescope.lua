return {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {'nvim-lua/plenary.nvim', {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
            return vim.fn.executable 'make' == 1
        end
    }, 'nvim-telescope/telescope-ui-select.nvim', {
        'nvim-tree/nvim-web-devicons',
        enabled = vim.g.have_nerd_font
    }},
    config = function()
        local telescope = require('telescope')
        local actions = require('telescope.actions')

        telescope.setup {
            defaults = {
                initial_mode = 'insert', -- Always start in insert mode
                mappings = {
                    i = {
                        ["<esc>"] = actions.close -- Close with a single Escape in insert mode
                    },
                    n = {
                        ["<esc>"] = actions.close -- Close with Escape in normal mode too
                    }
                }
            },
            extensions = {
                ['ui-select'] = {require('telescope.themes').get_dropdown()}
            }
        }

        -- Enable extensions if they are installed
        pcall(telescope.load_extension, 'fzf')
        pcall(telescope.load_extension, 'ui-select')

        -- Set keymaps
        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', '<leader>sh', builtin.help_tags, {
            desc = '[H]elp Search'
        })
        vim.keymap.set('n', '<leader>sk', builtin.keymaps, {
            desc = '[K]eymaps Search'
        })
        vim.keymap.set('n', '<leader>sf', builtin.find_files, {
            desc = '[F]iles Search '
        })
        vim.keymap.set('n', '<leader>st', builtin.builtin, {
            desc = '[T]elescope Search'
        })
        vim.keymap.set('n', '<leader>sw', builtin.grep_string, {
            desc = '[W]ord Search'
        })
        vim.keymap.set('n', '<leader>sg', builtin.live_grep, {
            desc = '[G]rep Search'
        })
        vim.keymap.set('n', '<leader>sd', builtin.diagnostics, {
            desc = '[D]iagnostics Search'
        })
        vim.keymap.set('n', '<leader>sr', builtin.resume, {
            desc = '[R]esume Search'
        })
        vim.keymap.set('n', '<leader>s.', builtin.oldfiles, {
            desc = '[.] Recent Files Search ("." for repeat)'
        })
        vim.keymap.set('n', '<leader>sb', builtin.buffers, {
            desc = '[B]uffers Search'
        })

        -- Fuzzy find in current buffer
        vim.keymap.set('n', '<leader>/', function()
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10,
                previewer = false
            })
        end, {
            desc = '[/] Fuzzily search in current buffer'
        })

        -- Search in open files
        vim.keymap.set('n', '<leader>s/', function()
            builtin.live_grep {
                grep_open_files = true,
                prompt_title = 'Live Grep in Open Files'
            }
        end, {
            desc = '[S]earch [/] in Open Files'
        })

        -- Search Neovim config files
        vim.keymap.set('n', '<leader>sn', function()
            builtin.find_files {
                cwd = vim.fn.stdpath 'config'
            }
        end, {
            desc = '[S]earch [N]eovim files'
        })
    end
}
