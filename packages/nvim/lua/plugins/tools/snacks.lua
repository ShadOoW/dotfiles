-- Snacks.nvim - Modern Neovim plugin collection
-- Comprehensive setup with Snacks picker as Telescope replacement
-- Keymaps: <leader>s* for all picker functions
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons', 'nvim-lua/plenary.nvim' },
  ---@type snacks.Config
  opts = {
    bigfile = {
      enabled = true,
    },
    input = {
      enabled = true,
    },
    layout = {
      enabled = true,
    },
    notifier = {
      enabled = true,
      keep = function(notif) return vim.fn.fnamemodify(notif.msg[1] or '', ':t') ~= 'mini.lua' end,
      history = true, -- Enable notification history for picker
      top_down = true,
      width = {
        min = 40,
        max = 0.4,
      },
      height = {
        min = 1,
        max = 0.6,
      },
      margin = {
        top = 0,
        right = 1,
        bottom = 0,
      },
      padding = {
        top = 1,
        right = 2,
        bottom = 1,
        left = 2,
      },
      sort = { 'level', 'added' },
      icons = {
        error = '󰅚',
        warn = '󰀪',
        info = '󰋽',
        debug = '󰌶',
        trace = '󰌶',
      },
      style = {
        wo = {
          winblend = 5,
        },
        border = 'rounded',
      },
    },
    quickfile = {
      enabled = true,
    },
    scroll = {
      enabled = true,
    },
    statuscolumn = {
      enabled = false,
    },
    terminal = {
      enabled = true,
    },
    toggle = {
      enabled = true,
    },
    util = {
      enabled = true,
    },
    win = {
      enabled = true,
    },
    rename = {
      enabled = true,
    },
    bufdelete = {
      enabled = true,
    },

    -- Snacks Picker Configuration
    picker = {
      enabled = true,
      ui_select = true,

      -- Enhanced backdrop for better transparency integration
      layout = {
        preset = function() return vim.o.columns >= 120 and 'ivy' or 'vertical' end,
        cycle = true,
        backdrop = {
          bg = 'none',
          blend = 90,
        }, -- Global backdrop transparency
      },

      -- Improved matcher configuration
      matcher = {
        fuzzy = true,
        smartcase = true,
        ignorecase = true,
        sort_empty = true,
        filename_bonus = true,
        frecency = true,
        history_bonus = true,
        cwd_bonus = true,
      },

      -- Sort configuration
      sort = {
        fields = { 'score:desc', 'frecency:desc', 'mtime:desc', '#text', 'idx' },
      },

      -- Enhanced formatters
      formatters = {
        file = {
          filename_first = true,
          filename_only = false,
          truncate = 80,
          icon_width = 2,
        },
        text = {
          ft = 'lua',
        },
      },

      -- Enhanced Tokyo Night theming with transparency
      win = {
        input = {
          border = 'rounded',
          title_pos = 'center',
          wo = {
            winblend = 10,
          }, -- Global transparency for input
          style = 'minimal',
        },
        list = {
          border = 'rounded',
          title_pos = 'center',
          wo = {
            winblend = 10,
          }, -- Global transparency for list
          style = 'minimal',
        },
        preview = {
          border = 'rounded',
          title_pos = 'center',
          wo = {
            winblend = 5,
          }, -- Subtle transparency for preview
          style = 'minimal',
        },
      },

      -- Custom icons
      icons = {
        file = '󰈙',
        folder = '󰉋',
        git = '󰊢',
        search = '󰍉',
        lsp = '󰒊',
        diagnostic = '󰞏',
        symbol = '󰒕',
        buffer = '󰈔',
        recent = '󱋢',
        help = '󰋗',
        command = '󰘳',
        keymap = '󰌋',
        quickfix = '󱖫',
        location = '󰌘',
        tag = '󰓻',
        aerial = '󰒪',
        notification = '󰎟',
        yank = '󰆐',
        tab = '󰓩',
        jump = '󰕰',
      },
    },
  },

  config = function(_, opts)
    local notify = require('utils.notify')
    local snacks = require('snacks')
    snacks.setup(opts)

    -- Helper function to create consistent picker configurations
    local function picker_config(title, icon, extra_opts)
      local config = {
        title = (icon and icon .. ' ' or '') .. title,
        prompt = '  ',
        layout = {
          preset = function() return vim.o.columns >= 120 and 'ivy' or 'vertical' end,
        },
      }

      if extra_opts then config = vim.tbl_deep_extend('force', config, extra_opts) end

      return config
    end

    -- ═══════════════════════════════════════════════════════════════════════════════
    -- SNACKS PICKER KEYMAPS - <leader>s prefix
    -- Complete Telescope functionality replacement with modern Snacks picker
    -- ═══════════════════════════════════════════════════════════════════════════════

    -- Core File Operations
    vim.keymap.set(
      'n',
      '<leader>sf',
      function()
        snacks.picker.files(picker_config('Find Files', '󰈞', {
          hidden = false,
          no_ignore = false,
        }))
      end,
      {
        desc = 'Find files',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>sF',
      function()
        snacks.picker.files(picker_config('Find Files (All)', '󰈞', {
          hidden = true,
          no_ignore = true,
        }))
      end,
      {
        desc = 'Find files (all/hidden)',
      }
    )

    vim.keymap.set('n', '<leader>sg', function() snacks.picker.grep(picker_config('Live Grep', '󰩉')) end, {
      desc = 'Live grep',
    })

    vim.keymap.set('n', '<leader>sw', function() snacks.picker.grep_word(picker_config('Grep Word', '󰩉')) end, {
      desc = 'Grep word under cursor',
    })

    vim.keymap.set(
      'n',
      '<leader>sb',
      function()
        snacks.picker.buffers(picker_config('Buffers', '󰈔', {
          sort = { 'mtime:desc' },
          show_unlisted = false,
        }))
      end,
      {
        desc = 'Find buffers',
      }
    )

    vim.keymap.set('n', '<leader>so', function()
      snacks.picker.recent({
        title = '󱋢 Recent Files',
        filter = {
          cwd = true,
        }, -- Filter to current working directory
      })
    end, {
      desc = 'Recent files',
    })

    vim.keymap.set(
      'n',
      '<leader>s.',
      function()
        snacks.picker.recent({
          title = '󱋢 Recent Files (All)',
        })
      end,
      {
        desc = 'Recent files (all)',
      }
    )

    -- Advanced Search
    vim.keymap.set(
      'n',
      '<leader>s/',
      function()
        snacks.picker.lines(picker_config('Current Buffer Lines', '󰍉', {
          current_buffer = true,
        }))
      end,
      {
        desc = 'Current buffer lines',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>s?',
      function()
        snacks.picker.grep(picker_config('Grep Open Files', '󰍉', {
          grep_open_files = true,
        }))
      end,
      {
        desc = 'Grep open files',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>sl',
      function() snacks.picker.lines(picker_config('Lines in All Buffers', '󰍉')) end,
      {
        desc = 'Lines in all buffers',
      }
    )

    -- Alternative command picker that doesn't override ':'
    vim.keymap.set('n', '<leader>:', function()
      snacks.picker.commands(picker_config('Commands', '󰘳', {
        -- Browse commands without executing (for exploration)
        actions = {
          default = function(item)
            -- Just show the command in command line for editing
            local cmd = item.cmd or item.text or item
            if type(cmd) == 'string' then vim.fn.feedkeys(':' .. cmd) end
          end,
          execute = function(item)
            -- Execute directly
            local cmd = item.cmd or item.text or item
            if type(cmd) == 'string' then
              vim.cmd(cmd)
              notify.success('Commands', 'Executed: ' .. cmd)
            end
          end,
        },
        keys = {
          ['<CR>'] = 'default', -- Put in command line
          ['<C-CR>'] = 'execute', -- Execute directly
          ['<C-c>'] = 'close', -- Close picker
          ['<Esc>'] = 'close', -- Close picker
          ['q'] = 'close', -- Close picker
          ['<C-q>'] = 'close', -- Close picker
        },
      }))
    end, {
      desc = 'Commands (Browse Mode)',
    })

    -- Quick command search (alternative to ':')
    vim.keymap.set('n', '<leader>sx', function()
      -- Show help notification
      notify.info('Commands Help', 'Enter=Execute, Tab=Preview, q/Esc=Quit, Ctrl+C=Cancel')

      snacks.picker.commands(picker_config('Search Commands', '󰘳', {
        actions = {
          default = function(item)
            local cmd = item.cmd or item.text or item
            if type(cmd) == 'string' then
              vim.cmd(cmd)
              notify.success('Commands', 'Executed: ' .. cmd)
            end
          end,
          preview = function(item)
            local cmd = item.cmd or item.text or item
            if type(cmd) == 'string' then notify.info('Commands', 'Preview: ' .. cmd) end
          end,
        },
        keys = {
          -- Execute commands
          ['<CR>'] = 'default',
          ['<C-CR>'] = 'default',

          -- Exit picker
          ['<Esc>'] = 'close',
          ['<C-c>'] = 'close',
          ['q'] = 'close',
          ['<C-q>'] = 'close',

          -- Navigation
          ['<C-j>'] = 'next',
          ['<C-k>'] = 'prev',
          ['<Down>'] = 'next',
          ['<Up>'] = 'prev',

          -- Preview
          ['<Tab>'] = 'preview',
          ['<C-p>'] = 'preview',
        },
        preview = {
          enabled = true,
        },
      }))
    end, {
      desc = 'Search Commands (Quick Access)',
    })

    -- Super quick command access with Ctrl+; (alternative to :)
    vim.keymap.set('n', '<C-;>', function()
      snacks.picker.commands(picker_config('Quick Commands', '󰘳', {
        actions = {
          default = function(item)
            local cmd = item.cmd or item.text or item
            if type(cmd) == 'string' then vim.cmd(cmd) end
          end,
        },
        keys = {
          ['<CR>'] = 'default',
          ['<Esc>'] = 'close',
          ['<C-c>'] = 'close',
          ['q'] = 'close',
        },
      }))
    end, {
      desc = 'Quick Commands (Ctrl+;)',
    })

    -- CTags picker - completely rewritten for proper preview support
    vim.keymap.set('n', '<leader>sc', function()
      -- Get all available tags using vim's taglist function
      local all_tags = vim.fn.taglist('.*')

      if #all_tags == 0 then
        notify.warn('CTags', 'No tags found. Make sure ctags are generated.')
        return
      end

      -- Convert tags to snacks picker format
      local items = {}
      for _, tag in ipairs(all_tags) do
        local filename = tag.filename
        -- Ensure absolute path
        if not vim.startswith(filename, '/') then filename = vim.fn.fnamemodify(filename, ':p') end

        -- Extract line number from cmd field
        local line_num = 1
        if tag.cmd then
          local cmd_line = tonumber(tag.cmd)
          if cmd_line then line_num = cmd_line end
        end

        -- Get kind icon
        local kind_icons = {
          f = '󰊕', -- function
          c = '󰠱', -- class
          m = '󰆧', -- method
          v = '󰀫', -- variable
          s = '󰏪', -- struct
          t = '󰗀', -- type
        }

        local kind = tag.kind or 'unknown'
        local icon = kind_icons[kind] or '󰓻'
        local basename = vim.fn.fnamemodify(filename, ':t')

        -- Create properly structured item for snacks picker
        table.insert(items, {
          text = string.format('%s %s (%s) - %s', icon, tag.name, kind, basename),
          file = filename,
          pos = { line_num, 1 },
          data = {
            name = tag.name,
            kind = kind,
            filename = filename,
            line = line_num,
          },
        })
      end

      -- Sort items by tag name
      table.sort(items, function(a, b) return a.data.name < b.data.name end)

      -- Use snacks picker with proper configuration
      snacks.picker.pick({
        title = '󰓻 CTags (' .. #items .. ' tags)',
        items = items,
        preview = true,
        actions = {
          default = function(item)
            vim.cmd('edit ' .. vim.fn.fnameescape(item.file))
            vim.api.nvim_win_set_cursor(0, item.pos)
            vim.cmd('normal! zz')
          end,
        },
      })
    end, {
      desc = 'CTags',
    })

    vim.keymap.set('n', '<leader>sk', function() snacks.picker.keymaps(picker_config('Keymaps', '󰌋')) end, {
      desc = 'Keymaps',
    })

    vim.keymap.set('n', '<leader>sh', function() snacks.picker.jumps(picker_config('Jump List', '󰕰')) end, {
      desc = 'Jump list',
    })

    vim.keymap.set('n', '<leader>sH', function() snacks.picker.help(picker_config('Help Tags', '󰋗')) end, {
      desc = 'Help tags',
    })

    vim.keymap.set('n', '<leader>sr', function() snacks.picker.resume() end, {
      desc = 'Resume last search',
    })

    vim.keymap.set('n', '<leader>s-', function() snacks.picker() end, {
      desc = 'Snacks pickers',
    })

    -- LSP Operations
    vim.keymap.set(
      'n',
      '<leader>sgd',
      function() snacks.picker.lsp_definitions(picker_config('LSP Definitions', '󰒊')) end,
      {
        desc = 'LSP definitions',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>sgD',
      function() snacks.picker.lsp_declarations(picker_config('LSP Declarations', '󰒊')) end,
      {
        desc = 'LSP declarations',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>si',
      function() snacks.picker.lsp_implementations(picker_config('LSP Implementations', '󰒊')) end,
      {
        desc = 'LSP implementations',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>st',
      function() snacks.picker.lsp_type_definitions(picker_config('LSP Type Definitions', '󰒊')) end,
      {
        desc = 'LSP type definitions',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>sR',
      function() snacks.picker.lsp_references(picker_config('LSP References', '󰒊')) end,
      {
        desc = 'LSP references',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>ss',
      function()
        snacks.picker.lsp_symbols(picker_config('Document Symbols', '󰒕', {
          symbols = 'document',
        }))
      end,
      {
        desc = 'Document symbols',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>sS',
      function()
        snacks.picker.lsp_symbols(picker_config('Workspace Symbols', '󰒕', {
          symbols = 'workspace',
        }))
      end,
      {
        desc = 'Workspace symbols',
      }
    )

    -- Diagnostics
    vim.keymap.set(
      'n',
      '<leader>se',
      function()
        snacks.picker.diagnostics(picker_config('Buffer Diagnostics', '󰞏', {
          current_buffer = true,
        }))
      end,
      {
        desc = 'Buffer diagnostics',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>sE',
      function() snacks.picker.diagnostics(picker_config('Workspace Diagnostics', '󰞏')) end,
      {
        desc = 'Workspace diagnostics',
      }
    )

    -- Git Operations
    vim.keymap.set('n', '<leader>sgf', function() snacks.picker.git_files(picker_config('Git Files', '󰊢')) end, {
      desc = 'Git files',
    })

    vim.keymap.set('n', '<leader>sgs', function() snacks.picker.git_status(picker_config('Git Status', '󰊢')) end, {
      desc = 'Git status',
    })

    vim.keymap.set(
      'n',
      '<leader>sgc',
      function()
        snacks.picker.git_log(picker_config('Git Commits', '󰊢', {
          current_buffer = false,
        }))
      end,
      {
        desc = 'Git commits',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>sgb',
      function()
        snacks.picker.git_log(picker_config('Git Buffer Commits', '󰊢', {
          current_buffer = true,
        }))
      end,
      {
        desc = 'Git buffer commits',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>sgB',
      function() snacks.picker.git_branches(picker_config('Git Branches', '󰊢')) end,
      {
        desc = 'Git branches',
      }
    )

    -- Quickfix and Lists
    vim.keymap.set('n', '<leader>sq', function() snacks.picker.qflist(picker_config('Quickfix List', '󱖫')) end, {
      desc = 'Quickfix list',
    })

    vim.keymap.set('n', '<leader>sQ', function() snacks.picker.loclist(picker_config('Location List', '󰌘')) end, {
      desc = 'Location list',
    })

    -- Project Operations
    vim.keymap.set(
      'n',
      '<leader>sp',
      function()
        snacks.picker.files(picker_config('Project Files', '󰈞', {
          cwd = '~/mnt/backup/code',
        }))
      end,
      {
        desc = 'Project files',
      }
    )

    vim.keymap.set('n', '<leader>sP', function()
      local input = vim.fn.input('Projects directory: ', '/mnt/backup/code')
      if input ~= '' then
        local expanded_path = vim.fn.expand(input)
        if vim.fn.isdirectory(expanded_path) == 1 then
          snacks.picker.files(picker_config('Project Files', '󰈞', {
            cwd = expanded_path,
          }))
        else
          notify.error('Project Files', 'Directory not found: ' .. expanded_path)
        end
      end
    end, {
      desc = 'Project files (choose directory)',
    })

    -- Enhanced Features
    vim.keymap.set('n', '<leader>sT', function()
      -- Check if we have any open tabs
      local tabs = vim.api.nvim_list_tabpages()
      if #tabs <= 1 then
        notify.warn('Tabs', 'No tabs to show')
        return
      end

      -- Create a simple tab picker
      local items = {}
      for i, tab in ipairs(tabs) do
        local win = vim.api.nvim_tabpage_get_win(tab)
        local buf = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buf)
        local display_name = name ~= '' and vim.fn.fnamemodify(name, ':t') or '[No Name]'

        table.insert(items, {
          text = string.format('Tab %d: %s', i, display_name),
          path = name,
          tab = tab,
          idx = i,
        })
      end

      snacks.picker.pick('tabs', {
        title = '󰓩 Tabs',
        items = items,
        actions = {
          default = function(item) vim.api.nvim_set_current_tabpage(item.tab) end,
          close = function(item)
            vim.api.nvim_set_current_tabpage(item.tab)
            vim.cmd('tabclose')
          end,
        },
      })
    end, {
      desc = 'Tabs',
    })

    -- Notifications and Messages
    vim.keymap.set('n', '<leader>sn', function()
      -- Use snacks notifier get_history API (correct method)
      local history = snacks.notifier.get_history()
      if not history or #history == 0 then
        notify.warn('Notifications', 'No notifications found.')
        return
      end

      local items = {}
      for i, notif in ipairs(history) do
        local message = notif.msg
        if type(message) == 'table' then message = table.concat(message, ' ') end

        -- Format notification for picker
        local level_icons = {
          [vim.log.levels.ERROR] = '󰅚',
          [vim.log.levels.WARN] = '󰀪',
          [vim.log.levels.INFO] = '󰋽',
          [vim.log.levels.DEBUG] = '󰌶',
        }

        local icon = level_icons[notif.level] or '󰋽'
        local title = notif.opts and notif.opts.title or 'Notification'
        local display_text = string.format('%s %s: %s', icon, title, tostring(message or ''))

        table.insert(items, {
          text = display_text,
          message = tostring(message or ''),
          level = notif.level,
          time = notif.time,
          title = title,
          icon = icon,
        })
      end

      -- Use snacks picker to display notifications
      snacks.picker.pick({
        source = 'list',
        items = items,
        title = '󰂚 Notification History',
        preview = function(item)
          return {
            '# ' .. item.title,
            '',
            'Level: '
              .. (
                item.level == vim.log.levels.ERROR and 'ERROR'
                or item.level == vim.log.levels.WARN and 'WARN'
                or item.level == vim.log.levels.INFO and 'INFO'
                or 'DEBUG'
              ),
            'Time: ' .. (item.time and os.date('%H:%M:%S', item.time) or 'Unknown'),
            '',
            '## Message:',
            item.message,
          }
        end,
      })
    end, {
      desc = 'Show notification history',
    })

    -- Yank History (if available)
    vim.keymap.set('n', '<leader>sy', function()
      local ok, yanky = pcall(require, 'yanky.history')
      if ok then
        local items = {}
        for i, entry in ipairs(yanky.all()) do
          -- Ensure we have valid text content
          local text_content = entry.regcontents
          if type(text_content) == 'table' then
            text_content = table.concat(text_content, '\n')
          elseif type(text_content) ~= 'string' then
            text_content = tostring(text_content or '')
          end

          table.insert(items, {
            text = text_content,
            regtype = entry.regtype,
            idx = i,
          })
        end

        snacks.picker.pick('yank_history', {
          title = '󰆐 Yank History',
          items = items,
          format = function(item)
            local text = item and item.text or ''
            if type(text) ~= 'string' then text = tostring(text) end
            return string.format('%s', text:gsub('\n', '\\n'))
          end,
          actions = {
            default = function(item)
              if item and item.text then
                vim.fn.setreg('"', item.text, item.regtype)
                vim.cmd('normal! ""p')
              end
            end,
          },
        })
      else
        notify.warn('Yank History', 'Yank history not available')
      end
    end, {
      desc = 'Yank history',
    })

    -- Buffer-specific shortcuts
    vim.keymap.set(
      'n',
      '<leader><leader>',
      function()
        snacks.picker.buffers(picker_config('Buffers', '󰈔', {
          sort = { 'mtime:desc' },
          show_unlisted = false,
          ignore_current_buffer = true,
        }))
      end,
      {
        desc = 'Buffers (quick access)',
      }
    )

    -- Quick grep with current word
    vim.keymap.set('n', '<C-S-f>', function() snacks.picker.grep(picker_config('Live Grep', '󰩉')) end, {
      desc = 'Quick live grep',
    })

    -- Quick file finder
    vim.keymap.set('n', '<C-p>', function() snacks.picker.files(picker_config('Find Files', '󰈞')) end, {
      desc = 'Quick file finder',
    })

    -- Project-scoped recent files (like telescope backslash)
    vim.keymap.set('n', '\\', function()
      snacks.picker.recent({
        title = '󰈞 Recent Files in Project',
        filter = {
          cwd = true,
        }, -- Filter to current working directory
      })
    end, {
      desc = 'Recent files in current project',
    })

    -- Set snacks as default notification handler to ensure history works
    vim.notify = snacks.notifier.notify

    -- Enhanced notification keymaps
    vim.keymap.set('n', '<leader>nh', function() snacks.notifier.show_history() end, {
      desc = 'Show notification history panel',
    })

    vim.keymap.set('n', '<leader>nd', function() snacks.notifier.hide() end, {
      desc = 'Dismiss all notifications',
    })

    -- Alternative keymap for notification history (same as <leader>sn)
    vim.keymap.set('n', '<leader>nn', function()
      -- Use snacks notifier get_history API (correct method)
      local history = snacks.notifier.get_history()
      if not history or #history == 0 then
        notify.warn('Notifications', 'No notifications found.')
        return
      end

      local items = {}
      for i, notif in ipairs(history) do
        local message = notif.msg
        if type(message) == 'table' then message = table.concat(message, ' ') end

        -- Format notification for picker
        local level_icons = {
          [vim.log.levels.ERROR] = '󰅚',
          [vim.log.levels.WARN] = '󰀪',
          [vim.log.levels.INFO] = '󰋽',
          [vim.log.levels.DEBUG] = '󰌶',
        }

        local icon = level_icons[notif.level] or '󰋽'
        local title = notif.opts and notif.opts.title or 'Notification'
        local display_text = string.format('%s %s: %s', icon, title, tostring(message or ''))

        table.insert(items, {
          text = display_text,
          message = tostring(message or ''),
          level = notif.level,
          time = notif.time,
          title = title,
          icon = icon,
        })
      end

      -- Use snacks picker to display notifications
      snacks.picker.pick({
        source = 'list',
        items = items,
        title = '󰂚 Notification History (Alt)',
        preview = function(item)
          return {
            '# ' .. item.title,
            '',
            'Level: '
              .. (
                item.level == vim.log.levels.ERROR and 'ERROR'
                or item.level == vim.log.levels.WARN and 'WARN'
                or item.level == vim.log.levels.INFO and 'INFO'
                or 'DEBUG'
              ),
            'Time: ' .. (item.time and os.date('%H:%M:%S', item.time) or 'Unknown'),
            '',
            '## Message:',
            item.message,
          }
        end,
      })
    end, {
      desc = 'Alternative notification history picker',
    })
  end,
}
