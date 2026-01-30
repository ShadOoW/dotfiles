local notify = require('utils.notify')

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
        -- Ensure background is truly transparent for all possible areas
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
          bg = c.bg_dark,
          fg = c.fg_sidebar,
        }
        hl.WinBarNC = {
          bg = c.bg_dark,
          fg = c.fg_gutter,
        }

        -- Fix areas that show when buffer is small or when scrolling
        hl.EndOfBuffer = {
          bg = 'NONE',
          fg = c.bg, -- Make the tildes nearly invisible
        }
        hl.NonText = {
          bg = 'NONE',
          fg = c.bg, -- Make non-text characters nearly invisible
        }
        hl.VertSplit = {
          bg = 'NONE',
          fg = c.border_highlight,
        }
        hl.WinSeparator = {
          bg = 'NONE',
          fg = c.border_highlight,
        }

        -- Fix all background elements
        hl.TabLine = {
          bg = 'NONE',
          fg = c.fg_gutter,
        }
        hl.TabLineFill = {
          bg = 'NONE',
        }
        hl.TabLineSel = {
          bg = 'NONE',
          fg = c.fg,
        }

        -- Fix fold column and other gutter elements
        hl.FoldColumn = {
          bg = 'NONE',
          fg = c.fg_gutter,
        }
        hl.Folded = {
          bg = 'NONE',
          fg = c.comment,
        }

        -- Fix cursor line and column
        hl.CursorLine = {
          bg = 'NONE',
        }
        hl.CursorColumn = {
          bg = 'NONE',
        }

        -- Enhanced Visual selection highlighting for better visibility with transparent background
        hl.Visual = {
          bg = '#0ea5e9', -- Bright cyan-blue background for maximum visibility
          fg = '#1a1b26', -- Dark foreground for excellent contrast
          bold = true, -- Add bold styling for extra emphasis
        }

        -- Make VisualNOS consistent with Visual for better UX
        hl.VisualNOS = {
          bg = '#0ea5e9', -- Same as Visual for consistency
          fg = '#1a1b26', -- Dark foreground for excellent contrast
          bold = true, -- Add bold styling for extra emphasis
        }

        -- Fix search highlighting
        hl.Search = {
          bg = c.bg_search,
          fg = c.fg,
        }
        hl.IncSearch = {
          bg = c.orange,
          fg = c.bg,
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

        -- Fix notification and diagnostic backgrounds with enhanced colors
        hl.DiagnosticSignError = {
          bg = 'NONE',
          fg = '#f7768e', -- Tokyo Night error red
        }
        hl.DiagnosticSignWarn = {
          bg = 'NONE',
          fg = '#e0af68', -- Bright yellow for better visibility
        }
        hl.DiagnosticSignInfo = {
          bg = 'NONE',
          fg = '#0db9d7', -- Tokyo Night info blue
        }
        hl.DiagnosticSignHint = {
          bg = 'NONE',
          fg = '#1abc9c', -- Tokyo Night hint teal
        }

        -- Enhanced diagnostic virtual text colors
        hl.DiagnosticVirtualTextError = {
          bg = 'NONE',
          fg = c.error,
          italic = true,
        }
        hl.DiagnosticVirtualTextWarn = {
          bg = 'NONE',
          fg = '#e0af68', -- Bright yellow for warnings
          italic = true,
        }
        hl.DiagnosticVirtualTextInfo = {
          bg = 'NONE',
          fg = c.info,
          italic = true,
        }
        hl.DiagnosticVirtualTextHint = {
          bg = 'NONE',
          fg = c.hint,
          italic = true,
        }

        -- Enhanced diagnostic underlines
        hl.DiagnosticUnderlineError = {
          undercurl = true,
          sp = c.error,
        }
        hl.DiagnosticUnderlineWarn = {
          undercurl = true,
          sp = '#e0af68', -- Bright yellow underline for warnings
        }
        hl.DiagnosticUnderlineInfo = {
          undercurl = true,
          sp = c.info,
        }
        hl.DiagnosticUnderlineHint = {
          undercurl = true,
          sp = c.hint,
        }

        -- Fix git signs background
        hl.GitSignsAdd = {
          bg = 'NONE',
          fg = c.git.add,
        }
        hl.GitSignsChange = {
          bg = 'NONE',
          fg = c.git.change,
        }
        hl.GitSignsDelete = {
          bg = 'NONE',
          fg = c.git.delete,
        }
      end,
    })

    -- Set colorscheme with error handling
    local ok, err = pcall(vim.cmd.colorscheme, 'tokyonight-night')
    if not ok then
      notify.warn('Tokyonight', 'Failed to load tokyonight-night: ' .. err)
      -- Fallback to default colorscheme
      vim.cmd.colorscheme('default')
    end

    -- Force transparency after colorscheme load
    vim.schedule(function()
      -- Core background elements
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
      vim.api.nvim_set_hl(0, 'CursorLineNr', {
        bg = 'NONE',
      })

      -- Areas visible when buffer is small or scrolling
      vim.api.nvim_set_hl(0, 'EndOfBuffer', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NonText', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'VertSplit', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'WinSeparator', {
        bg = 'NONE',
      })

      -- Tab and status elements
      vim.api.nvim_set_hl(0, 'TabLine', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'TabLineFill', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'TabLineSel', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'StatusLine', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'StatusLineNC', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'WinBar', {
        bg = '#1a1b26',
        fg = '#c0caf5',
      })
      vim.api.nvim_set_hl(0, 'WinBarNC', {
        bg = '#1a1b26',
        fg = '#565f89',
      })

      -- Fold and cursor elements
      vim.api.nvim_set_hl(0, 'FoldColumn', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'Folded', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'CursorLine', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'CursorColumn', {
        bg = 'NONE',
      })

      -- Enhanced Visual mode highlighting (force apply)
      vim.api.nvim_set_hl(0, 'Visual', {
        bg = '#0ea5e9', -- Solid, contrasting background for excellent visibility
        fg = '#1a1b26', -- Dark foreground for excellent contrast
        bold = true, -- Add bold styling for extra emphasis
      })

      -- Make VisualNOS consistent with Visual for better UX
      vim.api.nvim_set_hl(0, 'VisualNOS', {
        bg = '#0ea5e9', -- Same as Visual for consistency
        fg = '#1a1b26', -- Dark foreground for excellent contrast
        bold = true, -- Add bold styling for extra emphasis
      })

      -- Diagnostic and git signs with enhanced colors
      vim.api.nvim_set_hl(0, 'DiagnosticSignError', {
        bg = 'NONE',
        fg = '#f7768e', -- Tokyo Night error red
      })
      vim.api.nvim_set_hl(0, 'DiagnosticSignWarn', {
        bg = 'NONE',
        fg = '#e0af68', -- Bright yellow for better visibility
      })
      vim.api.nvim_set_hl(0, 'DiagnosticSignInfo', {
        bg = 'NONE',
        fg = '#0db9d7', -- Tokyo Night info blue
      })
      vim.api.nvim_set_hl(0, 'DiagnosticSignHint', {
        bg = 'NONE',
        fg = '#1abc9c', -- Tokyo Night hint teal
      })

      -- Enhanced diagnostic virtual text
      vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextWarn', {
        bg = 'NONE',
        fg = '#e0af68', -- Bright yellow for warnings
        italic = true,
      })

      -- Git signs
      vim.api.nvim_set_hl(0, 'GitSignsAdd', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'GitSignsChange', {
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'GitSignsDelete', {
        bg = 'NONE',
      })
    end)
  end,
}
