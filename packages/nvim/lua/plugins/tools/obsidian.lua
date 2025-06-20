-- Modern Obsidian.nvim based note-taking workflow
-- Focused on obsidian ecosystem plugins with Tokyo Night theme
return { -- Core obsidian.nvim plugin for seamless Obsidian vault integration
{
    'epwalsh/obsidian.nvim',
    version = '*',
    lazy = false,
    -- ft = 'markdown',
    dependencies = {'nvim-lua/plenary.nvim', 'hrsh7th/nvim-cmp', 'nvim-telescope/telescope.nvim',
                    'nvim-treesitter/nvim-treesitter'},
    opts = {
        workspaces = {{
            name = 'brain',
            path = '/mnt/share/brain'
        }},

        -- Daily notes configuration
        daily_notes = {
            folder = 'daily',
            date_format = '%Y-%m-%d',
            template = 'daily-note.md'
        },

        -- Note completion and linking
        completion = {
            nvim_cmp = true,
            min_chars = 2
        },

        -- Template configuration
        templates = {
            subdir = 'templates',
            date_format = '%Y-%m-%d',
            time_format = '%H:%M',
            substitutions = {
                -- Date substitutions for daily notes
                ['{{date:YYYYMMDD}}'] = function()
                    return os.date('%Y%m%d')
                end,
                ['{{date:YYYY-MM-DD}}'] = function()
                    return os.date('%Y-%m-%d')
                end,
                ['{{date:YYYY-MM-DD -1d}}'] = function()
                    local yesterday = os.time() - 24 * 60 * 60
                    return os.date('%Y-%m-%d', yesterday)
                end,
                ['{{date:YYYY-MM-DD +1d}}'] = function()
                    local tomorrow = os.time() + 24 * 60 * 60
                    return os.date('%Y-%m-%d', tomorrow)
                end,
                -- Additional commonly used date formats
                ['{{yesterday}}'] = function()
                    local yesterday = os.time() - 24 * 60 * 60
                    return os.date('%Y-%m-%d', yesterday)
                end,
                ['{{tomorrow}}'] = function()
                    local tomorrow = os.time() + 24 * 60 * 60
                    return os.date('%Y-%m-%d', tomorrow)
                end,
                ['{{today}}'] = function()
                    return os.date('%Y-%m-%d')
                end
            }
        },

        -- Note creation and naming
        new_notes_location = 'notes_subdir',
        notes_subdir = 'inbox',

        -- Custom note path function for daily notes
        note_path_func = function(spec)
            -- Ensure spec.dir is not nil and is a string
            if spec.dir and type(spec.dir) == 'string' and spec.dir:match('daily') then
                local date_str = spec.date and spec.date or os.date('%Y-%m-%d')
                return spec.dir .. '/' .. date_str .. '.md'
            end

            -- Default behavior for other notes - handle nil cases
            local dir = spec.dir or 'inbox'
            local id = spec.id or 'untitled'
            return dir .. '/' .. id .. '.md'
        end,

        -- Note ID generation with timestamp and slug
        note_id_func = function(title)
            -- For daily notes, let obsidian.nvim handle the ID (it will be the date)
            -- We can detect this is likely a daily note if no title is provided
            if not title or title == '' then
                -- Let obsidian.nvim use default daily note naming
                return nil
            end

            local suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
            return tostring(os.time()) .. '-' .. suffix
        end,

        -- Note frontmatter function - generate proper frontmatter for daily notes
        note_frontmatter_func = function(note)
            -- Debug: Print note info to help diagnose the issue
            -- vim.notify('Note path: ' .. tostring(note.path) .. ', ID: ' .. tostring(note.id), vim.log.levels.INFO)

            -- Multiple ways to detect daily notes
            local is_daily = false

            -- Method 1: Check path
            if note.path and type(note.path) == 'string' and note.path:match('daily/') then
                is_daily = true
            end

            -- Method 2: Check if filename looks like a date
            if note.path and type(note.path) == 'string' then
                local filename = vim.fs.basename(note.path)
                if filename:match('^%d%d%d%d%-%d%d%-%d%d%.md$') then
                    is_daily = true
                end
            end

            -- Method 3: Check if note.id looks like a date
            if note.id and type(note.id) == 'string' and note.id:match('^%d%d%d%d%-%d%d%-%d%d$') then
                is_daily = true
            end

            if is_daily then
                return {
                    id = '{{date:YYYYMMDD}}-dn',
                    date = '{{date:YYYY-MM-DD}}',
                    type = 'daily',
                    tags = {'daily', 'journal'}
                }
            end

            local out = {
                id = note.id,
                aliases = note.aliases,
                tags = note.tags
            }
            if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
                for k, v in pairs(note.metadata) do
                    out[k] = v
                end
            end
            return out
        end,

        -- Image handling configuration
        attachments = {
            img_folder = 'assets/images',
            img_text_func = function(client, path)
                local link_path
                local vault_relative_path = client:vault_relative_path(path)
                if vault_relative_path ~= nil then
                    link_path = vault_relative_path
                else
                    link_path = tostring(path)
                end
                local display_name = vim.fs.basename(link_path)
                return string.format('![%s](%s)', display_name, link_path)
            end
        },

        -- UI configuration with Tokyo Night colors
        -- UI disabled to prevent conflicts with render-markdown.nvim
        ui = {
            enable = false -- Disable obsidian.nvim UI to use render-markdown.nvim instead
        },

        -- Telescope integration
        finder = 'telescope.nvim',
        finder_mappings = {
            new = '<C-x>',
            insert_link = '<C-l>'
        },

        -- URL handling
        follow_url_func = function(url)
            vim.fn.jobstart({'xdg-open', url})
        end,

        -- Configuration options
        use_advanced_uri = false,
        open_app_foreground = false,
        sort_by = 'modified',
        sort_reversed = true,
        search_max_lines = 1000,
        open_notes_in = 'current'
    },

    config = function(_, opts)
        require('obsidian').setup(opts)

        -- Set conceallevel for markdown files to enable obsidian UI features
        -- Template insertion buffer fix (conceallevel handled globally in options.lua)
        local obsidian_group = vim.api.nvim_create_augroup('ObsidianTemplates', {
            clear = true
        })

        vim.api.nvim_create_autocmd('User', {
            group = obsidian_group,
            pattern = 'ObsidianTemplate*',
            callback = function()
                vim.opt_local.modifiable = true
            end
        })

        -- Simple template substitution function
        local function apply_substitutions()
            local buf = vim.api.nvim_get_current_buf()
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local modified = false

            -- Extract date from filename for context-aware substitutions
            local filename = vim.api.nvim_buf_get_name(buf)
            local date_from_filename = filename:match('(%d%d%d%d%-%d%d%-%d%d)')
            local target_time = os.time()

            if date_from_filename then
                local year, month, day = date_from_filename:match('(%d%d%d%d)%-(%d%d)%-(%d%d)')
                if year and month and day then
                    target_time = os.time({
                        year = tonumber(year),
                        month = tonumber(month),
                        day = tonumber(day),
                        hour = 12
                    })
                end
            end

            -- Apply substitutions to each line
            for i, line in ipairs(lines) do
                local new_line = line

                -- First handle link substitutions with .md extensions
                new_line = new_line:gsub('%[%[{{yesterday}}%]%]',
                    '[[' .. os.date('%Y-%m-%d', target_time - 24 * 60 * 60) .. '.md]]')
                new_line = new_line:gsub('%[%[{{tomorrow}}%]%]',
                    '[[' .. os.date('%Y-%m-%d', target_time + 24 * 60 * 60) .. '.md]]')
                new_line = new_line:gsub('%[%[{{today}}%]%]', '[[' .. os.date('%Y-%m-%d', target_time) .. '.md]]')

                -- Then handle regular date substitutions
                local substitutions = {
                    ['{{date:YYYYMMDD}}'] = os.date('%Y%m%d', target_time),
                    ['{{date:YYYY-MM-DD}}'] = os.date('%Y-%m-%d', target_time),
                    ['{{date:YYYY-MM-DD -1d}}'] = os.date('%Y-%m-%d', target_time - 24 * 60 * 60),
                    ['{{date:YYYY-MM-DD +1d}}'] = os.date('%Y-%m-%d', target_time + 24 * 60 * 60),
                    ['{{yesterday}}'] = os.date('%Y-%m-%d', target_time - 24 * 60 * 60),
                    ['{{tomorrow}}'] = os.date('%Y-%m-%d', target_time + 24 * 60 * 60),
                    ['{{today}}'] = os.date('%Y-%m-%d', target_time)
                }

                for pattern, replacement in pairs(substitutions) do
                    local escaped_pattern = pattern:gsub('([%[%]%(%)%+%-%*%?%^%$%%{}])', '%%%1')
                    new_line = new_line:gsub(escaped_pattern, replacement)
                end

                if new_line ~= line then
                    lines[i] = new_line
                    modified = true
                end
            end

            -- Update buffer if modifications were made
            if modified then
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                vim.notify('Template substitutions applied', vim.log.levels.INFO)
            else
                vim.notify('No substitutions found', vim.log.levels.WARN)
            end
        end

        -- Comprehensive key mappings for obsidian functionality
        local keymap = vim.keymap.set
        local opts_desc = {
            silent = true,
            noremap = true
        }

        -- Daily notes using obsidian.nvim built-in commands
        keymap('n', '<leader>ad', '<cmd>ObsidianToday<cr>', vim.tbl_extend('force', opts_desc, {
            desc = 'Open today note'
        }))
        keymap('n', '<leader>ay', '<cmd>ObsidianYesterday<cr>', vim.tbl_extend('force', opts_desc, {
            desc = 'Open yesterday note'
        }))
        keymap('n', '<leader>aT', '<cmd>ObsidianTomorrow<cr>', vim.tbl_extend('force', opts_desc, {
            desc = 'Open tomorrow note'
        }))

        -- Note management
        keymap('n', '<leader>an', '<cmd>ObsidianNew<cr>', vim.tbl_extend('force', opts_desc, {
            desc = 'Create new note'
        }))
        keymap('n', '<leader>ao', '<cmd>ObsidianOpen<cr>', vim.tbl_extend('force', opts_desc, {
            desc = 'Open note in obsidian'
        }))
        keymap('n', '<leader>ab', '<cmd>ObsidianBacklinks<cr>', vim.tbl_extend('force', opts_desc, {
            desc = 'Show backlinks'
        }))
        keymap('n', '<leader>al', '<cmd>ObsidianLinks<cr>', vim.tbl_extend('force', opts_desc, {
            desc = 'Show links'
        }))

        -- Search and navigation
        keymap('n', '<leader>af', '<cmd>ObsidianSearch<cr>', vim.tbl_extend('force', opts_desc, {
            desc = 'Search notes'
        }))
        keymap('n', '<leader>as', '<cmd>ObsidianQuickSwitch<cr>', vim.tbl_extend('force', opts_desc, {
            desc = 'Quick switch notes'
        }))
        keymap('n', '<leader>ag', '<cmd>ObsidianFollowLink<cr>', vim.tbl_extend('force', opts_desc, {
            desc = 'Follow link under cursor'
        }))

        -- Templates and utilities
        keymap('n', '<leader>ai', function()
            -- Ensure buffer is modifiable before template insertion
            vim.opt_local.modifiable = true
            vim.cmd('ObsidianTemplate')
        end, vim.tbl_extend('force', opts_desc, {
            desc = 'Insert template'
        }))
        keymap('n', '<leader>aS', apply_substitutions, vim.tbl_extend('force', opts_desc, {
            desc = 'Apply template substitutions'
        }))
        keymap('n', '<leader>ar', '<cmd>ObsidianRename<cr>', vim.tbl_extend('force', opts_desc, {
            desc = 'Rename note'
        }))
        keymap('v', '<leader>aL', ':ObsidianLinkNew<cr>', vim.tbl_extend('force', opts_desc, {
            desc = 'Create link from selection'
        }))

        -- Workspace and tags
        keymap('n', '<leader>aw', '<cmd>ObsidianWorkspace<cr>', vim.tbl_extend('force', opts_desc, {
            desc = 'Switch workspace'
        }))
        keymap('n', '<leader>at', '<cmd>ObsidianTags<cr>', vim.tbl_extend('force', opts_desc, {
            desc = 'Browse tags'
        }))
    end
}, -- Enhanced markdown rendering with Tokyo Night theme
{
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim'},
    ft = {'markdown', 'obsidian'},
    opts = {
        file_types = {'markdown', 'obsidian'},
        render_modes = {'n', 'c', 't'},
        anti_conceal = {
            enabled = true,
            above = 1,
            below = 1
        },
        heading = {
            enabled = true,
            sign = true,
            icons = {'󰲡 ', '󰲣 ', '�� ', '󰲧 ', '󰲩 ', '󰲫 '},
            width = 'full',
            left_margin = 0,
            left_pad = 0,
            right_pad = 0,
            min_width = 0,
            backgrounds = {'RenderMarkdownH1Bg', 'RenderMarkdownH2Bg', 'RenderMarkdownH3Bg', 'RenderMarkdownH4Bg',
                           'RenderMarkdownH5Bg', 'RenderMarkdownH6Bg'},
            foregrounds = {'RenderMarkdownH1', 'RenderMarkdownH2', 'RenderMarkdownH3', 'RenderMarkdownH4',
                           'RenderMarkdownH5', 'RenderMarkdownH6'}
        },
        code = {
            enabled = true,
            style = 'full',
            border = 'thin',
            left_margin = 0,
            left_pad = 1,
            right_pad = 1,
            highlight = 'RenderMarkdownCode',
            highlight_inline = 'RenderMarkdownCodeInline'
        },
        bullet = {
            enabled = true,
            icons = {'●', '○', '◆', '◇'},
            left_pad = 0,
            right_pad = 1,
            highlight = 'RenderMarkdownBullet'
        },
        checkbox = {
            enabled = true,
            position = 'inline',
            unchecked = {
                icon = '',
                highlight = 'RenderMarkdownUnchecked',
                scope_highlight = nil
            },
            checked = {
                icon = '󰱒',
                highlight = 'RenderMarkdownChecked',
                scope_highlight = nil
            },
            custom = {
                todo = {
                    raw = '[>]',
                    rendered = ' ',
                    highlight = 'RenderMarkdownTodo',
                    scope_highlight = nil
                },
                cancelled = {
                    raw = '[~]',
                    rendered = ' ',
                    highlight = 'RenderMarkdownCancelled',
                    scope_highlight = nil
                },
                urgent = {
                    raw = '[!]',
                    rendered = ' ',
                    highlight = 'RenderMarkdownUrgent',
                    scope_highlight = nil
                }
            }
        },
        callout = {
            note = {
                raw = '[!NOTE]',
                rendered = '󰋽 Note',
                highlight = 'RenderMarkdownInfo'
            },
            tip = {
                raw = '[!TIP]',
                rendered = '󰌶 Tip',
                highlight = 'RenderMarkdownSuccess'
            },
            important = {
                raw = '[!IMPORTANT]',
                rendered = '󰅾 Important',
                highlight = 'RenderMarkdownHint'
            },
            warning = {
                raw = '[!WARNING]',
                rendered = '󰀪 Warning',
                highlight = 'RenderMarkdownWarn'
            },
            caution = {
                raw = '[!CAUTION]',
                rendered = '󰳦 Caution',
                highlight = 'RenderMarkdownError'
            }
        },
        link = {
            enabled = true,
            image = '󰥶 ',
            hyperlink = '󰌹 ',
            highlight = 'RenderMarkdownLink',
            custom = {
                obsidian = {
                    pattern = '%[%[.*%]%]',
                    icon = '󰆼 ',
                    highlight = 'RenderMarkdownLink'
                }
            }
        },
        sign = {
            enabled = true,
            highlight = 'RenderMarkdownSign'
        }
    },
    config = function(_, opts)
        require('render-markdown').setup(opts)

        -- Tokyo Night themed highlight groups
        local colors = {
            h1 = '#ff7a93',
            h2 = '#b4f9f8',
            h3 = '#ffc777',
            h4 = '#c3e88d',
            h5 = '#82aaff',
            h6 = '#c792ea',
            code = '#565f89',
            bullet = '#7dcfff',
            checkbox = '#9ece6a'
        }

        -- Apply Tokyo Night colors to markdown elements
        vim.api.nvim_set_hl(0, 'RenderMarkdownH1', {
            fg = colors.h1,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH2', {
            fg = colors.h2,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH3', {
            fg = colors.h3,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH4', {
            fg = colors.h4,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH5', {
            fg = colors.h5,
            bold = true
        })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH6', {
            fg = colors.h6,
            bold = true
        })

        vim.api.nvim_set_hl(0, 'RenderMarkdownCode', {
            bg = colors.code
        })
        vim.api.nvim_set_hl(0, 'RenderMarkdownCodeInline', {
            bg = colors.code,
            fg = '#ff9e64'
        })
        vim.api.nvim_set_hl(0, 'RenderMarkdownBullet', {
            fg = colors.bullet
        })
        vim.api.nvim_set_hl(0, 'RenderMarkdownChecked', {
            fg = colors.checkbox
        })
        vim.api.nvim_set_hl(0, 'RenderMarkdownUnchecked', {
            fg = '#565f89'
        })
        vim.api.nvim_set_hl(0, 'RenderMarkdownLink', {
            fg = '#73daca',
            underline = true
        })

        -- Callout highlights
        vim.api.nvim_set_hl(0, 'RenderMarkdownInfo', {
            fg = '#7dcfff'
        })
        vim.api.nvim_set_hl(0, 'RenderMarkdownSuccess', {
            fg = '#9ece6a'
        })
        vim.api.nvim_set_hl(0, 'RenderMarkdownWarn', {
            fg = '#e0af68'
        })
        vim.api.nvim_set_hl(0, 'RenderMarkdownError', {
            fg = '#f7768e'
        })
    end
}, -- Enhanced markdown table editing
{
    'dhruvasagar/vim-table-mode',
    ft = {'markdown', 'obsidian'},
    config = function()
        vim.g.table_mode_corner = '|'
        vim.g.table_mode_delimiter = ' | '
        vim.g.table_mode_fillchar = '-'

        vim.keymap.set('n', '<leader>am', '<cmd>TableModeToggle<cr>', {
            desc = 'Toggle table mode'
        })
        vim.keymap.set('n', '<leader>ar', '<cmd>TableModeRealign<cr>', {
            desc = 'Realign table'
        })
    end
}, -- Clipboard image support
{
    'HakonHarnes/img-clip.nvim',
    event = 'VeryLazy',
    ft = {'markdown', 'obsidian'},
    opts = {
        filetypes = {
            markdown = {
                url_encode_path = true,
                template = '![$CURSOR]($FILE_PATH)',
                dir_path = 'assets/images'
            },
            obsidian = {
                url_encode_path = true,
                template = '![$CURSOR]($FILE_PATH)',
                dir_path = 'assets/images'
            }
        }
    },
    keys = {{
        '<leader>ac',
        '<cmd>PasteImage<cr>',
        desc = 'Paste clipboard image'
    }}
}, -- Enhanced folding for markdown
{
    'masukomi/vim-markdown-folding',
    ft = {'markdown', 'obsidian'},
    config = function()
        vim.g.markdown_fold_style = 'nested'
        vim.g.markdown_fold_override_foldtext = 0
    end
}}
