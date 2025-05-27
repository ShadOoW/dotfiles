return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    -- Get colors from Tokyo Night theme to match tmux
    local colors = {
      bg = '#1a1b26',
      fg = '#c0caf5',
      yellow = '#e0af68',
      cyan = '#7dcfff',
      darkblue = '#7aa2f7',
      green = '#9ece6a',
      orange = '#ff9e64',
      violet = '#bb9af7',
      magenta = '#bb9af7',
      blue = '#7aa2f7',
      red = '#f7768e',
    }

    local conditions = {
      buffer_not_empty = function() return vim.fn.empty(vim.fn.expand('%:t')) ~= 1 end,
      hide_in_width = function() return vim.fn.winwidth(0) > 80 end,
      check_git_workspace = function()
        local filepath = vim.fn.expand('%:p:h')
        local gitdir = vim.fn.finddir('.git', filepath .. ';')
        return gitdir and #gitdir > 0 and #gitdir < #filepath
      end,
    }

    local config = {
      options = {
        component_separators = '',
        section_separators = '',
        theme = {
          normal = {
            a = {
              fg = colors.fg,
              bg = colors.bg,
            },
            b = {
              fg = colors.fg,
              bg = colors.bg,
            },
            c = {
              fg = colors.fg,
              bg = colors.bg,
            },
            z = {
              fg = colors.fg,
              bg = colors.bg,
            },
          },
          inactive = {
            a = {
              fg = colors.fg,
              bg = colors.bg,
            },
            b = {
              fg = colors.fg,
              bg = colors.bg,
            },
            c = {
              fg = colors.fg,
              bg = colors.bg,
            },
          },
        },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = {
          {
            'mode',
            color = function()
              local mode_color = {
                n = colors.blue,
                i = colors.green,
                v = colors.magenta,
                [''] = colors.magenta,
                V = colors.magenta,
                c = colors.orange,
                no = colors.red,
                s = colors.orange,
                S = colors.orange,
                [''] = colors.orange,
                ic = colors.yellow,
                R = colors.violet,
                Rv = colors.violet,
                cv = colors.red,
                ce = colors.red,
                r = colors.cyan,
                rm = colors.cyan,
                ['r?'] = colors.cyan,
                ['!'] = colors.red,
                t = colors.red,
              }
              return {
                fg = mode_color[vim.fn.mode()] or colors.fg,
              }
            end,
            padding = {
              left = 1,
              right = 1,
            },
          },
        },
        lualine_b = {
          {
            'branch',
            icon = '',
            color = {
              fg = colors.violet,
              gui = 'bold',
            },
          },
          {
            'diff',
            symbols = {
              added = ' ',
              modified = ' ',
              removed = ' ',
            },
            diff_color = {
              added = {
                fg = colors.green,
              },
              modified = {
                fg = colors.orange,
              },
              removed = {
                fg = colors.red,
              },
            },
            cond = conditions.hide_in_width,
          },
        },
        lualine_c = {
          {
            'filename',
            file_status = true,
            path = 1,
            shorting_target = 40,
            symbols = {
              modified = '[+]',
              readonly = '[-]',
              unnamed = '[No Name]',
            },
          },
        },
        lualine_x = {
          {
            'diagnostics',
            sources = {
              'nvim_diagnostic',
            },
            symbols = {
              error = ' ',
              warn = ' ',
              info = ' ',
            },
            diagnostics_color = {
              color_error = {
                fg = colors.red,
              },
              color_warn = {
                fg = colors.yellow,
              },
              color_info = {
                fg = colors.cyan,
              },
            },
          },
          {
            function()
              local msg = 'No LSP'
              local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
              local clients = vim.lsp.get_active_clients()
              if next(clients) == nil then return msg end
              for _, client in ipairs(clients) do
                local filetypes = client.config.filetypes
                if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then return client.name end
              end
              return msg
            end,
            icon = ' LSP:',
            color = {
              fg = colors.violet,
              gui = 'bold',
            },
          },
        },
        lualine_y = {
          {
            'filetype',
            colored = true,
            icon_only = false,
            icon = {
              align = 'right',
            },
            color = {
              fg = colors.green,
              gui = 'bold',
            },
          },
          {
            'progress',
            color = {
              fg = colors.fg,
              gui = 'bold',
            },
          },
        },
        lualine_z = {
          {
            'location',
            color = {
              fg = colors.fg,
              gui = 'bold',
            },
          },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          'filename',
        },
        lualine_x = {
          'location',
        },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    }

    require('lualine').setup(config)
  end,
}
