-- Telescope themes and custom configurations
-- Centralized theme management for consistent telescope experience
return {
    'nvim-telescope/telescope.nvim',
    dependencies = {'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-ui-select.nvim'},
    config = function()
        local telescope = require('telescope')
        local themes = require('telescope.themes')
        local builtin = require('telescope.builtin')

        -- Unified ivy theme with consistent settings for all pickers
        local function get_ivy_theme(opts)
            return themes.get_ivy(vim.tbl_deep_extend('force', {
                layout_config = {
                    height = 0.5, -- Consistent height for all ivy pickers
                    preview_cutoff = 120,
                    preview_width = 0.6
                },
                borderchars = {
                    preview = {'─', '│', '─', '│', '╭', '╮', '╯', '╰'},
                    prompt = {'─', '│', ' ', '│', '╭', '╮', '│', '│'},
                    results = {'─', '│', '─', '│', '├', '┤', '╯', '╰'}
                },
                results_title = false,
                prompt_title = false,
                sorting_strategy = 'ascending',
                layout_strategy = 'bottom_pane'
            }, opts or {}))
        end

        -- Enhanced keymaps with unified ivy theme
        local function setup_enhanced_keymaps()
            -- Core Search Functions
            vim.keymap.set('n', '<leader>sf', function()
                builtin.find_files(get_ivy_theme({
                    prompt_title = ' 󰈞 Find Files',
                    hidden = false,
                    no_ignore = false
                }))
            end, {
                desc = 'Files'
            })

            vim.keymap.set('n', '<leader>sg', function()
                builtin.live_grep(get_ivy_theme({
                    prompt_title = ' 󰩉 Live Grep'
                }))
            end, {
                desc = 'Grep'
            })

            vim.keymap.set('n', '<leader>sw', function()
                builtin.grep_string(get_ivy_theme({
                    prompt_title = ' 󰩉 Grep String Under Cursor'
                }))
            end, {
                desc = 'Grep string under cursor'
            })

            vim.keymap.set('n', '<leader><leader>', function()
                builtin.buffers(get_ivy_theme({
                    prompt_title = '  Buffers',
                    show_all_buffers = true,
                    sort_lastused = true,
                    ignore_current_buffer = true,
                    sort_mru = true
                }))
            end, {
                desc = 'Buffers'
            })

            vim.keymap.set('n', '<leader>s.', function()
                builtin.oldfiles(get_ivy_theme({
                    prompt_title = ' 󱋢 Recent Files',
                    only_cwd = true
                }))
            end, {
                desc = 'Recent files'
            })

            -- Enhanced Telescope Functions
            vim.keymap.set('n', '<leader>s-', builtin.builtin, {
                desc = 'Telescope pickers'
            })
            vim.keymap.set('n', '<leader>sr', builtin.resume, {
                desc = 'Resume last search'
            })
            vim.keymap.set('n', '<leader>sH', builtin.help_tags, {
                desc = 'Help tags'
            })
            vim.keymap.set('n', '<leader>sk', builtin.keymaps, {
                desc = 'Keymaps'
            })
            vim.keymap.set('n', '<leader>sd', function()
                builtin.diagnostics(get_ivy_theme({
                    bufnr = nil,
                    severity_sort = true,
                    severity_limit = vim.diagnostic.severity.WARN
                }))
            end, {
                desc = 'Diagnostics'
            })

            -- Advanced Search Functions
            vim.keymap.set('n', '<leader>s/', function()
                builtin.current_buffer_fuzzy_find(get_ivy_theme({
                    prompt_title = ' 󰩉 Current Buffer Search'
                }))
            end, {
                desc = 'Current buffer'
            })

            vim.keymap.set('n', '<leader>s?', function()
                builtin.live_grep({
                    grep_open_files = true,
                    prompt_title = 'Live Grep in Open Buffers'
                })
            end, {
                desc = 'Open buffers'
            })

            vim.keymap.set('n', '<leader>sp', function()
                builtin.find_files({
                    cwd = '~/mnt/backup/code',
                    prompt_title = 'Project Files'
                })
            end, {
                desc = 'Project files'
            })

            vim.keymap.set('n', '<leader>sP', function()
                -- Interactive projects directory selector
                local input = vim.fn.input('Projects directory (default: /mnt/backup/code): ', '/mnt/backup/code')
                if input ~= '' then
                    local expanded_path = vim.fn.expand(input)
                    if vim.fn.isdirectory(expanded_path) == 1 then
                        builtin.find_files({
                            cwd = expanded_path,
                            prompt_title = 'Project Files (' .. vim.fn.fnamemodify(expanded_path, ':~') .. ')'
                        })
                    else
                        vim.notify('Directory not found: ' .. expanded_path, vim.log.levels.ERROR)
                    end
                end
            end, {
                desc = 'Project files (choose directory)'
            })

            -- Telescope tabs extension
            vim.keymap.set('n', '<leader>st', function()
                require('telescope').extensions['telescope-tabs'].list_tabs(get_ivy_theme({
                    prompt_title = '  Tabs'
                }))
            end, {
                desc = 'Tabs'
            })

            vim.keymap.set('n', '<leader>tS', function()
                -- Check if LSP is available
                local clients = vim.lsp.get_clients({
                    bufnr = 0
                })
                if #clients == 0 then
                    vim.notify('No LSP client attached', vim.log.levels.WARN)
                    return
                end

                builtin.lsp_workspace_symbols(get_ivy_theme({
                    prompt_title = '  Workspace Symbols'
                }))
            end, {
                desc = 'Workspace Symbols',
                silent = true
            })

            vim.keymap.set('n', '<leader>sh', function()
                builtin.jumplist(get_ivy_theme({
                    prompt_title = '  Locations History',
                    only_sort_tags = true
                }))
            end, {
                desc = 'Locations History',
                silent = true
            })

            vim.keymap.set('n', '<leader>sc', function()
                builtin.tags(get_ivy_theme({
                    prompt_title = ' 󰓻 Project cTags',
                    only_sort_tags = true
                }))
            end, {
                desc = 'Project Tags (ctags)',
                silent = true
            })

            -- Telescope aerial integration
            vim.keymap.set('n', '<leader>sa', function()
                require('telescope').extensions.aerial.aerial(get_ivy_theme({
                    prompt_title = '  Aerial Symbols'
                }))
            end, {
                desc = 'Telescope Aerial',
                silent = true
            })

            -- Notification history with unified ivy theme
            vim.keymap.set('n', '<leader>sn', function()
                require('telescope').extensions.notify.notify(get_ivy_theme({
                    prompt_title = ' 󰎟 Notification History'
                }))
            end, {
                desc = 'Notification History'
            })

            -- Yank history with unified ivy theme
            vim.keymap.set('n', '<leader>sy', function()
                local success, _ = pcall(function()
                    require('telescope').extensions.yank_history.yank_history(get_ivy_theme({
                        prompt_title = '  Yank History'
                    }))
                end)
                if not success then
                    vim.notify('Yank history extension not available', vim.log.levels.WARN)
                end
            end, {
                desc = 'Yank history'
            })

            vim.keymap.set('n', '<C-f>', function()
                builtin.live_grep(get_ivy_theme())
            end, {
                desc = 'Quick live grep'
            })

            vim.keymap.set('n', '<leader>fF', function()
                builtin.find_files(get_ivy_theme({
                    prompt_title = ' 󰈞 Find Files (All)',
                    hidden = true,
                    no_ignore = true
                }))
            end, {
                desc = 'Find files (include hidden)'
            })

            -- Live grep with unified ivy
            vim.keymap.set('n', '<leader>fg', function()
                builtin.live_grep(get_ivy_theme({
                    prompt_title = ' 󰩉 Live Grep',
                    additional_args = {'--hidden'}
                }))
            end, {
                desc = 'Live grep'
            })

            -- Buffer operations
            vim.keymap.set('n', '<leader>sb', function()
                builtin.buffers(get_ivy_theme({
                    prompt_title = '  Buffers',
                    show_all_buffers = true,
                    sort_lastused = true,
                    ignore_current_buffer = false,
                    sort_mru = true
                }))
            end, {
                desc = 'Find buffers'
            })

            -- Git operations
            vim.keymap.set('n', '<leader>gc', function()
                builtin.git_commits(get_ivy_theme({
                    prompt_title = '  Git Commits'
                }))
            end, {
                desc = 'Git commits'
            })

            vim.keymap.set('n', '<leader>gb', function()
                builtin.git_branches(get_ivy_theme({
                    prompt_title = '  Git Branches'
                }))
            end, {
                desc = 'Git branches'
            })

            vim.keymap.set('n', '<leader>gs', function()
                builtin.git_status(get_ivy_theme({
                    prompt_title = ' 󰊢 Git Status'
                }))
            end, {
                desc = 'Git status'
            })

            -- LSP operations with unified ivy theme
            vim.keymap.set('n', '<leader>lr', function()
                builtin.lsp_references(get_ivy_theme({
                    prompt_title = '  LSP References',
                    fname_width = 50,
                    show_line = true
                }))
            end, {
                desc = 'LSP references'
            })

            vim.keymap.set('n', '<leader>ld', function()
                builtin.lsp_definitions(get_ivy_theme({
                    prompt_title = '  LSP Definitions',
                    fname_width = 50,
                    show_line = true
                }))
            end, {
                desc = 'LSP definitions'
            })

            vim.keymap.set('n', '<leader>li', function()
                builtin.lsp_implementations(get_ivy_theme({
                    prompt_title = '  LSP Implementations',
                    fname_width = 50,
                    show_line = true
                }))
            end, {
                desc = 'LSP implementations'
            })

            vim.keymap.set('n', '<leader>lt', function()
                builtin.lsp_type_definitions(get_ivy_theme({
                    prompt_title = '  LSP Type Definitions',
                    fname_width = 50,
                    show_line = true
                }))
            end, {
                desc = 'LSP type definitions'
            })

            -- Diagnostics
            vim.keymap.set('n', '<leader>lD', function()
                builtin.diagnostics(get_ivy_theme({
                    prompt_title = ' 󰞏 Workspace Diagnostics',
                    bufnr = nil -- All buffers
                }))
            end, {
                desc = 'Workspace diagnostics'
            })

            vim.keymap.set('n', '<leader>ld', function()
                builtin.diagnostics(get_ivy_theme({
                    prompt_title = ' 󰞏 Buffer Diagnostics',
                    bufnr = 0 -- Current buffer only
                }))
            end, {
                desc = 'Buffer diagnostics'
            })

            -- Quickfix and loclist
            vim.keymap.set('n', '<leader>qf', function()
                builtin.quickfix(get_ivy_theme({
                    prompt_title = ' 󱖫 Quickfix List'
                }))
            end, {
                desc = 'Quickfix list'
            })

            vim.keymap.set('n', '<leader>ql', function()
                builtin.loclist(get_ivy_theme({
                    prompt_title = '  Location List'
                }))
            end, {
                desc = 'Location list'
            })

            -- Commands and keymaps
            vim.keymap.set('n', '<leader>:', function()
                builtin.commands(get_ivy_theme({
                    prompt_title = ' 󰘳 Commands'
                }))
            end, {
                desc = 'Commands'
            })

            vim.keymap.set('n', '<leader>?', function()
                builtin.keymaps(get_ivy_theme({
                    prompt_title = ' 󰌋 Keymaps'
                }))
            end, {
                desc = 'Keymaps'
            })

            -- Symbols with unified display
            vim.keymap.set('n', '<leader>ss', function()
                builtin.lsp_document_symbols(get_ivy_theme({
                    prompt_title = '  Document Symbols',
                    symbol_width = 50,
                    symbol_type_width = 12,
                    fname_width = 30,
                    show_line = true
                }))
            end, {
                desc = 'Document symbols'
            })

            vim.keymap.set('n', '<leader>sS', function()
                builtin.lsp_dynamic_workspace_symbols(get_ivy_theme({
                    prompt_title = '  Workspace Symbols',
                    fname_width = 50,
                    show_line = true
                }))
            end, {
                desc = 'Workspace symbols'
            })
        end

        -- Setup the enhanced keymaps
        setup_enhanced_keymaps()

        -- '\' - Project-scoped frecency file finder
        vim.keymap.set('n', '\\', function()
            local cwd = vim.fn.getcwd()
            require('telescope').extensions.frecency.frecency(get_ivy_theme({
                cwd = cwd,
                previewer = false,
                prompt_title = ' 󰈞 Recent Files: ' .. vim.fn.fnamemodify(cwd, ':t'),
                workspace = 'project', -- Use project workspace for scoping
                no_ignore = false
            }))
        end, {
            desc = 'Find recent files in current project'
        })

        -- Create user commands for theme switching
        vim.api.nvim_create_user_command('TelescopeIvyMode', function()
            vim.g.telescope_theme_mode = 'ivy'
            vim.notify('Telescope: Ivy theme mode enabled', vim.log.levels.INFO)
        end, {
            desc = 'Switch to Ivy theme mode'
        })

        vim.api.nvim_create_user_command('TelescopeDropdownMode', function()
            vim.g.telescope_theme_mode = 'dropdown'
            vim.notify('Telescope: Dropdown theme mode enabled', vim.log.levels.INFO)
        end, {
            desc = 'Switch to Dropdown theme mode'
        })

        vim.api.nvim_create_user_command('TelescopeDefaultMode', function()
            vim.g.telescope_theme_mode = nil
            vim.notify('Telescope: Default theme mode enabled', vim.log.levels.INFO)
        end, {
            desc = 'Switch to Default theme mode'
        })
    end
}
