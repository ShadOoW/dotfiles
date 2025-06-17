-- Modern Noice configuration for compact notifications
-- Compact 1-line notifications with level icons
return {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {'MunifTanjim/nui.nvim', 'nvim-treesitter/nvim-treesitter'},
    config = function()
        -- Override vim.notify before setting up noice
        local original_notify = vim.notify
        vim.notify = function(msg, level, opts)
            opts = opts or {}
            if type(msg) == 'table' then
                msg = table.concat(msg, ' ')
            end
            msg = tostring(msg or '')

            local icons = {
                [vim.log.levels.ERROR] = '',
                [vim.log.levels.WARN] = '',
                [vim.log.levels.INFO] = '',
                [vim.log.levels.DEBUG] = '',
                [vim.log.levels.TRACE] = ''
            }

            level = level or vim.log.levels.INFO
            local icon = icons[level] or ''

            -- Format message as: icon | message
            local clean_msg = msg:gsub('%s*\n%s*', ' '):gsub('%s+', ' '):gsub('^%s*(.-)%s*$', '%1')
            local formatted_msg = string.format('%s | %s', icon, clean_msg)

            return original_notify(formatted_msg, level, opts)
        end

        require('noice').setup({
            -- Disable commands to prevent unwanted panels
            commands = {
                enabled = false
            },

            -- LSP integration
            lsp = {
                override = {
                    ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                    ['vim.lsp.util.stylize_markdown'] = true,
                    ['cmp.entry.get_documentation'] = true
                },
                progress = {
                    enabled = true,
                    format = 'lsp_progress',
                    format_done = 'lsp_progress_done',
                    throttle = 1000 / 30,
                    view = 'mini'
                },
                hover = {
                    enabled = true,
                    silent = true
                },
                signature = {
                    enabled = true,
                    auto_open = {
                        enabled = true,
                        trigger = true,
                        luasnip = true,
                        throttle = 50
                    }
                },
                message = {
                    enabled = true,
                    view = 'notify'
                },
                documentation = {
                    view = 'hover',
                    opts = {
                        lang = 'markdown',
                        replace = true,
                        render = 'plain',
                        format = {'{message}'},
                        win_options = {
                            concealcursor = 'n',
                            conceallevel = 3
                        }
                    }
                }
            },

            -- Modern presets for better UX
            presets = {
                bottom_search = true,
                command_palette = false,
                long_message_to_split = true,
                inc_rename = true,
                lsp_doc_border = true
            },

            -- Views configuration
            views = {
                -- Compact notification view
                notify = {
                    backend = 'notify',
                    fallback = 'mini',
                    format = 'notify',
                    replace = false,
                    merge = false
                },

                -- Command line popup
                cmdline_popup = {
                    position = {
                        row = '50%',
                        col = '50%'
                    },
                    size = {
                        width = 60,
                        height = 'auto'
                    },
                    border = {
                        style = 'single',
                        padding = {0, 1}
                    },
                    win_options = {
                        winhighlight = {
                            Normal = 'NoiceCmdlinePopup',
                            FloatBorder = 'NoiceCmdlinePopupBorder',
                            CursorLine = 'PmenuSel',
                            Search = 'None'
                        }
                    }
                },

                -- Mini view for progress messages
                mini = {
                    backend = 'mini',
                    relative = 'editor',
                    align = 'message-right',
                    timeout = 3000,
                    reverse = true,
                    focusable = false,
                    position = {
                        row = -2,
                        col = '100%'
                    },
                    size = 'auto',
                    border = {
                        style = 'none'
                    },
                    win_options = {
                        winblend = 0,
                        winhighlight = {
                            Normal = 'NoiceMini',
                            IncSearch = '',
                            CurSearch = '',
                            Search = ''
                        }
                    }
                },

                -- Split view for long messages
                split = {
                    enter = true,
                    relative = 'editor',
                    position = 'bottom',
                    size = '20%',
                    close = {
                        keys = {'q', '<Esc>'}
                    },
                    win_options = {
                        winhighlight = {
                            Normal = 'Normal',
                            FloatBorder = 'FloatBorder'
                        }
                    }
                }
            },

            -- Enhanced message routing to prevent cmdline interference
            routes = { -- === PRIORITY 1: Keep cmdline clear ===
            -- Allow all command line input
            {
                filter = {
                    event = 'cmdline'
                },
                view = 'cmdline'
            }, -- Only allow genuine command input in cmdline
            {
                filter = {
                    event = 'cmdline',
                    kind = 'search'
                },
                view = 'cmdline'
            }, {
                filter = {
                    event = 'cmdline',
                    kind = 'filter'
                },
                view = 'cmdline'
            }, {
                filter = {
                    event = 'cmdline',
                    kind = 'lua'
                },
                view = 'cmdline'
            }, {
                filter = {
                    event = 'cmdline',
                    kind = ''
                },
                view = 'cmdline'
            }, -- === PRIORITY 2: Route confirmations appropriately ===
            -- Critical confirmations that require user interaction - use popup
            {
                filter = {
                    event = 'msg_show',
                    any = {{
                        find = '%[Y/n%]'
                    }, {
                        find = '%[y/N%]'
                    }, {
                        find = '%[Y/N/C%]'
                    }, {
                        find = 'Save changes'
                    }, {
                        find = 'Overwrite existing file'
                    }, {
                        find = 'No write since last change'
                    }, {
                        find = 'continue%?'
                    }, {
                        find = 'Press ENTER'
                    }}
                },
                view = 'cmdline_popup'
            }, -- === PRIORITY 3: Route all errors to notifications ===
            -- All Vim error messages (E123: pattern)
            {
                filter = {
                    event = 'msg_show',
                    find = 'E%d+:'
                },
                view = 'notify'
            }, -- Lua execution errors
            {
                filter = {
                    event = 'msg_show',
                    any = {{
                        find = 'Error executing lua:'
                    }, {
                        find = 'Error executing vim%.schedule lua callback'
                    }, {
                        find = 'stack traceback:'
                    }, {
                        kind = 'emsg'
                    }, {
                        kind = 'echoerr'
                    }}
                },
                view = 'notify'
            }, -- General error patterns
            {
                filter = {
                    event = 'msg_show',
                    any = {{
                        error = true
                    }, {
                        find = '^Error'
                    }, {
                        find = 'ERROR:'
                    }, {
                        find = 'Failed'
                    }}
                },
                view = 'notify'
            }, -- === PRIORITY 4: Route warnings to notifications ===
            {
                filter = {
                    event = 'msg_show',
                    any = {{
                        warning = true
                    }, {
                        find = '^Warning'
                    }, {
                        find = 'WARNING:'
                    }, {
                        kind = 'wmsg'
                    }}
                },
                view = 'notify'
            }, -- === PRIORITY 5: Route LSP messages appropriately ===
            -- LSP progress messages to mini view
            {
                filter = {
                    event = 'lsp',
                    kind = 'progress'
                },
                view = 'mini'
            }, -- LSP messages and notifications
            {
                filter = {
                    event = 'lsp',
                    any = {{
                        kind = 'message'
                    }, {
                        kind = 'info'
                    }}
                },
                view = 'notify'
            }, -- Filter out noisy LSP progress from lua_ls
            {
                filter = {
                    event = 'lsp',
                    kind = 'progress',
                    cond = function(message)
                        local client = vim.tbl_get(message.opts, 'progress', 'client')
                        return client == 'lua_ls'
                    end
                },
                opts = {
                    skip = true
                }
            }, -- === PRIORITY 6: Route notifications and info messages ===
            -- Plugin notifications and info messages
            {
                filter = {
                    event = 'notify'
                },
                view = 'notify'
            }, -- General informational messages
            {
                filter = {
                    event = 'msg_show',
                    any = {{
                        kind = 'echo'
                    }, {
                        kind = 'echomsg'
                    }, {
                        find = 'INFO:'
                    }}
                },
                view = 'notify'
            }, -- === PRIORITY 7: Handle special cases ===
            -- Skip noisy file operations
            {
                filter = {
                    event = 'msg_show',
                    any = {{
                        find = 'written'
                    }, {
                        find = '%d+L, %d+B'
                    }, {
                        find = '"; %d+L, %d+B'
                    }}
                },
                opts = {
                    skip = true
                }
            }, -- Skip search count messages
            {
                filter = {
                    event = 'msg_show',
                    kind = 'search_count'
                },
                opts = {
                    skip = true
                }
            }, -- Skip recording messages
            {
                filter = {
                    event = 'msg_show',
                    find = 'recording'
                },
                opts = {
                    skip = true
                }
            }, -- === PRIORITY 8: Route editing feedback to mini view ===
            {
                filter = {
                    event = 'msg_show',
                    any = {{
                        find = '; after #%d+'
                    }, {
                        find = '; before #%d+'
                    }, {
                        find = '%d fewer lines'
                    }, {
                        find = '%d more lines'
                    }, {
                        find = '%d+ changes?'
                    }, {
                        find = 'Already at newest change'
                    }, {
                        find = 'Already at oldest change'
                    }}
                },
                view = 'mini'
            }, -- === PRIORITY 9: Route long messages to split ===
            {
                filter = {
                    event = 'msg_show',
                    min_height = 8,
                    cond = function()
                        return vim.fn.getcmdwintype() == ''
                    end
                },
                view = 'split'
            }, -- === PRIORITY 10: Route ALL remaining msg_show events ===
            -- This ensures NOTHING interferes with cmdline unless explicitly allowed above
            {
                filter = {
                    event = 'msg_show',
                    -- Don't catch confirmations (handled above)
                    ['not'] = {
                        any = {{
                            find = '%[Y/n%]'
                        }, {
                            find = '%[y/N%]'
                        }, {
                            find = '%[Y/N/C%]'
                        }}
                    }
                },
                view = 'notify'
            }, -- === PRIORITY 11: Catch any remaining message events ===
            -- Skip mode and command messages to prevent lualine interference
            {
                filter = {
                    event = 'msg_showmode'
                },
                opts = {
                    skip = true
                }
            }, {
                filter = {
                    event = 'msg_showcmd'
                },
                opts = {
                    skip = true
                }
            }, {
                filter = {
                    event = 'msg_ruler'
                },
                opts = {
                    skip = true
                } -- Skip ruler updates
            }, {
                filter = {
                    event = 'msg_history_show'
                },
                view = 'split'
            }, -- === PRIORITY 12: Ultimate fallback ===
            -- Catch any other message that might slip through
            {
                filter = {
                    any = {{
                        event = 'msg_show'
                    }, {
                        event = 'msg_ruler'
                    }, {
                        event = 'msg_history_show'
                    }},
                    ['not'] = {
                        any = {{
                            event = 'cmdline'
                        }, {
                            find = '%[Y/n%]'
                        }, {
                            find = '%[y/N%]'
                        }, {
                            find = '%[Y/N/C%]'
                        }}
                    }
                },
                view = 'notify'
            }},

            -- Built-in notification backend settings
            notify = {
                enabled = true,
                view = 'notify'
            },

            -- Message settings
            messages = {
                enabled = true,
                view = 'notify',
                view_error = 'notify',
                view_warn = 'notify',
                view_history = 'messages',
                view_search = 'virtualtext'
            },

            -- Command line settings with nerd font icons
            cmdline = {
                enabled = true,
                view = 'cmdline_popup',
                opts = {
                    position = {
                        row = '100%',
                        col = '50%'
                    },
                    size = {
                        width = 60,
                        height = 'auto'
                    },
                    border = {
                        style = 'rounded',
                        padding = {0, 1}
                    },
                    win_options = {
                        winhighlight = {
                            Normal = 'NoiceCmdlinePopup',
                            FloatBorder = 'NoiceCmdlinePopupBorder',
                            IncSearch = '',
                            CurSearch = '',
                            Search = ''
                        }
                    }
                },
                format = {
                    cmdline = {
                        pattern = '^:',
                        icon = '󰘳',
                        lang = 'vim'
                    },
                    search_down = {
                        kind = 'search',
                        pattern = '^/',
                        icon = '󱦞',
                        lang = 'regex'
                    },
                    search_up = {
                        kind = 'search',
                        pattern = '^%?',
                        icon = '󱦞',
                        lang = 'regex'
                    },
                    filter = {
                        pattern = '^:%s*!',
                        icon = '',
                        lang = 'bash'
                    },
                    lua = {
                        pattern = {'^:%s*lua%s+', '^:%s*lua%s*=%s*', '^:%s*=%s*'},
                        icon = '󰢱',
                        lang = 'lua'
                    },
                    help = {
                        pattern = '^:%s*he?l?p?%s+',
                        icon = '󰮥'
                    },
                    input = {
                        view = 'cmdline_popup',
                        icon = '󰭙'
                    }
                }
            },

            -- Popup menu settings
            popupmenu = {
                enabled = true,
                backend = 'nui',
                kind_icons = {}
            },

            -- Format configuration
            format = {
                level = {
                    hl_group = 'NoiceFormatLevel'
                },
                date = {
                    hl_group = 'NoiceFormatDate'
                },
                title = {
                    hl_group = 'NoiceFormatTitle'
                },
                event = {
                    hl_group = 'NoiceFormatEvent'
                },
                kind = {
                    hl_group = 'NoiceFormatKind'
                },
                data = {
                    hl_group = 'NoiceFormatData'
                }
            },

            -- Health check settings
            health = {
                checker = false
            }
        })

        -- Set up Tokyo Night inspired colors for Noice
        vim.api.nvim_set_hl(0, 'NoiceConfirm', {
            bg = '#414868',
            fg = '#c0caf5'
        })
        vim.api.nvim_set_hl(0, 'NoiceConfirmBorder', {
            fg = '#7aa2f7'
        })
        vim.api.nvim_set_hl(0, 'NoiceCmdline', {
            bg = 'NONE', -- Transparent background to not interfere with terminal
            fg = '#c0caf5'
        })
        vim.api.nvim_set_hl(0, 'NoiceCmdlineIcon', {
            fg = '#7aa2f7'
        })
        vim.api.nvim_set_hl(0, 'NoiceCmdlinePopup', {
            bg = '#1a1b26'
        })
        vim.api.nvim_set_hl(0, 'NoiceCmdlinePopupBorder', {
            fg = '#565f89'
        })
        vim.api.nvim_set_hl(0, 'NoiceCompletionItemKindDefault', {
            fg = '#9ece6a'
        })
        vim.api.nvim_set_hl(0, 'NoiceMini', {
            bg = '#1a1b26',
            fg = '#c0caf5'
        })

        -- Add missing format highlight groups
        vim.api.nvim_set_hl(0, 'NoiceFormatLevel', {
            fg = '#7aa2f7'
        })
        vim.api.nvim_set_hl(0, 'NoiceFormatDate', {
            fg = '#565f89'
        })
        vim.api.nvim_set_hl(0, 'NoiceFormatTitle', {
            fg = '#c0caf5',
            bold = true
        })
        vim.api.nvim_set_hl(0, 'NoiceFormatEvent', {
            fg = '#9ece6a'
        })
        vim.api.nvim_set_hl(0, 'NoiceFormatKind', {
            fg = '#f7768e'
        })
        vim.api.nvim_set_hl(0, 'NoiceFormatData', {
            fg = '#c0caf5'
        })

        -- Custom keymaps for better UX
        vim.keymap.set('n', '<leader>nn', '<cmd>Noice<cr>', {
            desc = 'Noice Messages'
        })
        vim.keymap.set('n', '<leader>nh', '<cmd>Noice history<cr>', {
            desc = 'Noice History'
        })
        vim.keymap.set('n', '<leader>nd', '<cmd>Noice dismiss<cr>', {
            desc = 'Dismiss Noice Messages'
        })
        vim.keymap.set('n', '<leader>ne', '<cmd>Noice errors<cr>', {
            desc = 'Noice Errors'
        })
    end,

    -- Keybindings for enhanced scroll control
    keys = {{
        '<S-Enter>',
        function()
            local cmdline = vim.fn.getcmdline()
            if cmdline and cmdline ~= '' then
                require('noice').redirect(cmdline)
            end
        end,
        mode = 'c',
        desc = 'Redirect command to split'
    }, {
        '<c-f>',
        function()
            if not require('noice.lsp').scroll(4) then
                return '<c-f>'
            end
        end,
        silent = true,
        expr = true,
        desc = 'Scroll forward',
        mode = {'i', 'n', 's'}
    }, {
        '<c-b>',
        function()
            if not require('noice.lsp').scroll(-4) then
                return '<c-b>'
            end
        end,
        silent = true,
        expr = true,
        desc = 'Scroll backward',
        mode = {'i', 'n', 's'}
    }}
}
