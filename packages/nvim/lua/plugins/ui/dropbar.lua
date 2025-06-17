return {
  'Bekaboo/dropbar.nvim',
  dependencies = { 'nvim-telescope/telescope-fzf-native.nvim', 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',
  config = function()
    require('dropbar').setup({
      -- General settings
      enable = function(buf, win, _)
        -- Enable for most filetypes, disable for special buffers
        local excluded_filetypes = {
          'help',
          'startify',
          'dashboard',
          'neo-tree',
          'neotest-summary',
          'trouble',
          'aerial',
          'alpha',
          'lir',
          'outline',
          'spectre_panel',
          'toggleterm',
          'DressingSelect',
          'Jaq',
          'harpoon',
          'lab',
          'notify',
          'noice',
          'neotest-output',
          'neotest-summary',
          'neotest-output-panel',
        }

        local buftype = vim.api.nvim_get_option_value('buftype', {
          buf = buf,
        })
        local filetype = vim.api.nvim_get_option_value('filetype', {
          buf = buf,
        })

        -- Disable for special buffer types
        if buftype ~= '' then return false end

        -- Disable for excluded filetypes
        if vim.tbl_contains(excluded_filetypes, filetype) then return false end

        -- Enable for regular files
        return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
      end,

      -- Icons configuration
      icons = {
        kinds = {
          symbols = {
            Array = '󰅪 ',
            Boolean = ' ',
            Class = '󰠱 ',
            Color = '󰏘 ',
            Constant = '󰏿 ',
            Constructor = ' ',
            Enum = ' ',
            EnumMember = ' ',
            Event = ' ',
            Field = ' ',
            File = '󰈙 ',
            Folder = '󰉋 ',
            Function = '󰊕 ',
            Interface = ' ',
            Key = '󰌋 ',
            Keyword = '󰌋 ',
            Method = '󰆧 ',
            Module = ' ',
            Namespace = '󰌗 ',
            Null = '󰟢 ',
            Number = ' ',
            Object = '󰅩 ',
            Operator = '󰆕 ',
            Package = ' ',
            Property = ' ',
            Reference = '󰈇 ',
            Snippet = ' ',
            String = '󰀬 ',
            Struct = '󰙅 ',
            Text = '󰉿 ',
            TypeParameter = '󰊄 ',
            Unit = '󰑭 ',
            Value = '󰎠 ',
            Variable = '󰀫 ',
          },
        },
        ui = {
          bar = {
            separator = ' 󰁕 ',
            extends = '󰇘',
          },
          menu = {
            separator = ' ',
            indicator = ' 󰁕 ',
          },
        },
      },

      -- Symbol configuration
      symbol = {
        preview = {
          -- Preview window configuration
          reorient_when_invisible = true,
        },
        jump = {
          -- Jump behavior
          reorient = true,
        },
      },

      -- Bar configuration
      bar = {
        hover = true,
        sources = function(buf, _)
          local sources = require('dropbar.sources')
          local utils = require('dropbar.utils')

          local filetype = vim.api.nvim_get_option_value('filetype', {
            buf = buf,
          })

          -- For markdown files, use a simpler approach
          if filetype == 'markdown' then
            return { sources.path, utils.source.fallback({ sources.treesitter, sources.markdown, sources.lsp }) }
          end

          -- For most file types, use treesitter with LSP fallback
          if vim.bo[buf].buftype == '' then
            return { sources.path, utils.source.fallback({ sources.lsp, sources.treesitter }) }
          end

          -- Fallback for special buffers
          return { sources.path }
        end,
        padding = {
          left = 1,
          right = 1,
        },
        pick = {
          pivots = 'abcdefghijklmnopqrstuvwxyz',
        },
        truncate = true,
      },

      -- Menu configuration
      menu = {
        -- Enable quick navigation
        quick_navigation = true,
        entry = {
          padding = {
            left = 1,
            right = 1,
          },
        },
        -- Scrollbar configuration
        scrollbar = {
          enable = true,
        },
        -- Menu keymaps
        keymaps = {
          ['<LeftMouse>'] = function()
            local menu = require('dropbar.utils').menu.get_current()
            if not menu then return end
            local mouse = vim.fn.getmousepos()
            local clicked_menu = mouse.winid == menu.win
            -- If clicked in the menu window, handle the click
            if clicked_menu then menu:click_at({ mouse.line, mouse.column }, nil, 1, 'l') end
          end,
          ['<CR>'] = function()
            local menu = require('dropbar.utils').menu.get_current()
            if not menu then return end
            local cursor = vim.api.nvim_win_get_cursor(menu.win)
            menu:click_at(cursor, nil, 1, 'l')
          end,
          ['<MouseMove>'] = function()
            local menu = require('dropbar.utils').menu.get_current()
            if not menu then return end
            local mouse = vim.fn.getmousepos()
            if mouse.winid ~= menu.win then return end
            menu:update_hover_hl({ mouse.line, mouse.column })
          end,
          ['q'] = function()
            local menu = require('dropbar.utils').menu.get_current()
            if menu then menu:close() end
          end,
          ['<Esc>'] = function()
            local menu = require('dropbar.utils').menu.get_current()
            if menu then menu:close() end
          end,
          ['<Up>'] = function()
            local menu = require('dropbar.utils').menu.get_current()
            if menu and menu.prev then menu:prev() end
          end,
          ['<Down>'] = function()
            local menu = require('dropbar.utils').menu.get_current()
            if menu and menu.next then menu:next() end
          end,
          ['k'] = function()
            local menu = require('dropbar.utils').menu.get_current()
            if menu and menu.prev then menu:prev() end
          end,
          ['j'] = function()
            local menu = require('dropbar.utils').menu.get_current()
            if menu and menu.next then menu:next() end
          end,
        },
      },

      -- Fzf integration
      fzf = {
        keymaps = {
          ['<LeftMouse>'] = function()
            local menu = require('dropbar.utils').menu.get_current()
            if not menu then return end
            local mouse = vim.fn.getmousepos()
            if mouse.winid == menu.win then menu:click_at({ mouse.line, mouse.column }, nil, 1, 'l') end
          end,
        },
        win_configs = {
          relative = 'cursor',
          anchor = 'NW',
        },
      },
    })

    -- Custom keybindings
    vim.keymap.set('n', '<leader>ad', function() require('dropbar.api').pick() end, {
      desc = 'Pick from dropbar',
    })

    -- Custom highlight groups to match your theme
    vim.schedule(function()
      -- Dropbar background and foreground
      vim.api.nvim_set_hl(0, 'DropBarKindFile', {
        fg = '#89b4fa',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'DropBarKindFolder', {
        fg = '#fab387',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'DropBarKindFunction', {
        fg = '#cba6f7',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'DropBarKindMethod', {
        fg = '#cba6f7',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'DropBarKindClass', {
        fg = '#f9e2af',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'DropBarKindInterface', {
        fg = '#f9e2af',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'DropBarKindVariable', {
        fg = '#94e2d5',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'DropBarKindConstant', {
        fg = '#f38ba8',
        bg = 'NONE',
      })

      -- Menu highlights
      vim.api.nvim_set_hl(0, 'DropBarMenuNormalFloat', {
        fg = '#cdd6f4',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'DropBarMenuFloatBorder', {
        fg = '#6c7086',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'DropBarMenuHoverEntry', {
        fg = '#cdd6f4',
        bg = '#313244',
      })
      vim.api.nvim_set_hl(0, 'DropBarMenuCurrentContext', {
        fg = '#f9e2af',
        bg = 'NONE',
        bold = true,
      })

      -- Icon separator
      vim.api.nvim_set_hl(0, 'DropBarIconUISeparator', {
        fg = '#6c7086',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'DropBarIconUIIndicator', {
        fg = '#89b4fa',
        bg = 'NONE',
      })
    end)
  end,
}
