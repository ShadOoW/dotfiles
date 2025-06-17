return {
  'folke/tokyonight.nvim',
  priority = 1000, -- Load before other start plugins
  config = function()
    require('tokyonight').setup({
      style = 'night', -- Explicitly set to night variant
      light_style = 'day', -- Fallback for light mode
      transparent = true, -- Enable transparency
      terminal_colors = true, -- Configure terminal colors
      styles = {
        comments = {
          italic = false,
        }, -- Disable italics in comments
        keywords = {
          italic = false,
        }, -- Disable italics in keywords
        functions = {},
        variables = {},
        sidebars = 'transparent', -- Transparent sidebars
        floats = 'transparent', -- Transparent floating windows
      },
      sidebars = { 'qf', 'help', 'vista_kind', 'terminal', 'packer' }, -- Set sidebar filetypes to transparent
      day_brightness = 0.3, -- Adjusts brightness of day style
      hide_inactive_statusline = false, -- Don't hide statusline on inactive windows
      dim_inactive = false, -- Don't dim inactive windows
      lualine_bold = false, -- Don't bold lualine section headers

      -- Override specific highlight groups for better transparency
      on_highlights = function(hl, c)
        -- Ensure background is truly transparent
        hl.Normal = {
          bg = 'NONE',
          fg = c.fg,
        }
        hl.NormalNC = {
          bg = 'NONE',
          fg = c.fg,
        }
        hl.NormalFloat = {
          bg = 'NONE',
          fg = c.fg,
        }
        hl.FloatBorder = {
          bg = 'NONE',
          fg = c.border_highlight,
        }
        hl.SignColumn = {
          bg = 'NONE',
          fg = c.fg_gutter,
        }
        hl.LineNr = {
          bg = 'NONE',
          fg = c.fg_gutter,
        }
        hl.CursorLineNr = {
          bg = 'NONE',
          fg = c.orange,
        }
        hl.StatusLine = {
          bg = 'NONE',
          fg = c.fg_sidebar,
        }
        hl.StatusLineNC = {
          bg = 'NONE',
          fg = c.fg_gutter,
        }
        hl.WinBar = {
          bg = 'NONE',
          fg = c.fg_sidebar,
        }
        hl.WinBarNC = {
          bg = 'NONE',
          fg = c.fg_gutter,
        }

        -- Fix Telescope transparency
        hl.TelescopeNormal = {
          bg = 'NONE',
          fg = c.fg,
        }
        hl.TelescopeBorder = {
          bg = 'NONE',
          fg = c.border_highlight,
        }
        hl.TelescopePromptNormal = {
          bg = 'NONE',
          fg = c.fg,
        }
        hl.TelescopePromptBorder = {
          bg = 'NONE',
          fg = c.border_highlight,
        }
        hl.TelescopeResultsNormal = {
          bg = 'NONE',
          fg = c.fg,
        }
        hl.TelescopeResultsBorder = {
          bg = 'NONE',
          fg = c.border_highlight,
        }
        hl.TelescopePreviewNormal = {
          bg = 'NONE',
          fg = c.fg,
        }
        hl.TelescopePreviewBorder = {
          bg = 'NONE',
          fg = c.border_highlight,
        }

        -- Fix popup menu transparency
        hl.Pmenu = {
          bg = c.bg_popup,
          fg = c.fg,
        }
        hl.PmenuSel = {
          bg = c.bg_visual,
          fg = c.fg,
        }
        hl.PmenuSbar = {
          bg = c.bg_popup,
        }
        hl.PmenuThumb = {
          bg = c.fg_gutter,
        }
      end,
    })

    -- Set colorscheme with error handling
    local ok, err = pcall(vim.cmd.colorscheme, 'tokyonight-night')
    if not ok then
      vim.notify('Failed to load tokyonight-night: ' .. err, vim.log.levels.WARN)
      -- Fallback to default colorscheme
      vim.cmd.colorscheme('default')
    end

    -- Force transparency after colorscheme load
    vim.schedule(function()
      vim.api.nvim_set_hl(0, 'Normal', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NormalNC', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NormalFloat', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'SignColumn', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'LineNr', {
        bg = 'NONE',
      })
    end)
  end,
}
