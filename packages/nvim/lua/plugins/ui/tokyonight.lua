local notify = require('utils.notify')

return {
  'folke/tokyonight.nvim',
  priority = 1000, -- Load before other start plugins
  config = function()
    require('tokyonight').setup({
      style = 'night', -- Explicitly set to night variant
      light_style = 'day', -- Fallback for light mode
      transparent = false, -- Solid backgrounds for better text readability
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
        sidebars = 'dark', -- Solid sidebars
        floats = 'dark', -- Solid floating windows
      },
      sidebars = { 'qf', 'help', 'vista_kind', 'terminal', 'packer' },
      day_brightness = 0.3, -- Adjusts brightness of day style
      hide_inactive_statusline = false, -- Don't hide statusline on inactive windows
      dim_inactive = true, -- Dim inactive windows to highlight focused panel
      lualine_bold = false, -- Don't bold lualine section headers

      -- Override specific highlight groups for solid backgrounds
      on_highlights = function(hl, c)
        hl.Normal = {
          bg = c.bg,
          fg = c.fg,
        }
        hl.NormalNC = {
          bg = c.bg_dark, -- Dim inactive windows (works with dim_inactive)
          fg = c.fg,
        }
        hl.NormalFloat = {
          bg = c.bg,
          fg = c.fg,
        }
        hl.FloatBorder = {
          bg = c.bg_dark,
          fg = c.border_highlight,
        }
        hl.SignColumn = {
          bg = c.bg_dark,
          fg = c.fg_gutter,
        }
        hl.LineNr = {
          bg = c.bg_dark,
          fg = c.fg_gutter,
        }
        hl.CursorLineNr = {
          bg = c.bg_dark,
          fg = c.orange,
        }
        hl.StatusLine = {
          bg = c.bg_dark,
          fg = c.fg_sidebar,
        }
        hl.StatusLineNC = {
          bg = c.bg_dark,
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

        hl.EndOfBuffer = {
          bg = c.bg,
          fg = c.bg,
        }
        hl.NonText = {
          bg = c.bg,
          fg = c.bg,
        }
        hl.VertSplit = {
          bg = c.bg_dark,
          fg = c.border_highlight,
        }
        hl.WinSeparator = {
          bg = c.bg_dark,
          fg = c.border_highlight,
        }

        hl.TabLine = {
          bg = c.bg_dark,
          fg = c.fg_gutter,
        }
        hl.TabLineFill = {
          bg = c.bg_dark,
        }
        hl.TabLineSel = {
          bg = c.bg_dark,
          fg = c.fg,
        }

        hl.FoldColumn = {
          bg = c.bg_dark,
          fg = c.fg_gutter,
        }
        hl.Folded = {
          bg = c.bg_dark,
          fg = c.comment,
        }

        hl.CursorLine = {
          bg = c.bg_visual,
        }
        hl.CursorColumn = {
          bg = c.bg_visual,
        }

        -- Enhanced Visual selection highlighting
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

        hl.TelescopeNormal = {
          bg = c.bg,
          fg = c.fg,
        }
        hl.TelescopeBorder = {
          bg = c.bg_dark,
          fg = c.border_highlight,
        }
        hl.TelescopePromptNormal = {
          bg = c.bg,
          fg = c.fg,
        }
        hl.TelescopePromptBorder = {
          bg = c.bg_dark,
          fg = c.border_highlight,
        }
        hl.TelescopeResultsNormal = {
          bg = c.bg,
          fg = c.fg,
        }
        hl.TelescopeResultsBorder = {
          bg = c.bg_dark,
          fg = c.border_highlight,
        }
        hl.TelescopePreviewNormal = {
          bg = c.bg,
          fg = c.fg,
        }
        hl.TelescopePreviewBorder = {
          bg = c.bg_dark,
          fg = c.border_highlight,
        }

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

        hl.DiagnosticSignError = {
          bg = c.bg_dark,
          fg = '#f7768e', -- Tokyo Night error red
        }
        hl.DiagnosticSignWarn = {
          bg = c.bg_dark,
          fg = '#e0af68', -- Bright yellow for better visibility
        }
        hl.DiagnosticSignInfo = {
          bg = c.bg_dark,
          fg = '#0db9d7', -- Tokyo Night info blue
        }
        hl.DiagnosticSignHint = {
          bg = c.bg_dark,
          fg = '#1abc9c', -- Tokyo Night hint teal
        }

        hl.DiagnosticVirtualTextError = {
          bg = c.bg_dark,
          fg = c.error,
          italic = true,
        }
        hl.DiagnosticVirtualTextWarn = {
          bg = c.bg_dark,
          fg = '#e0af68',
          italic = true,
        }
        hl.DiagnosticVirtualTextInfo = {
          bg = c.bg_dark,
          fg = c.info,
          italic = true,
        }
        hl.DiagnosticVirtualTextHint = {
          bg = c.bg_dark,
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

        -- Gitsigns sign column (bar colors distinguish add vs change vs delete)
        hl.GitSignsAdd    = { bg = c.bg_dark, fg = '#73daca' } -- teal-green
        hl.GitSignsChange = { bg = c.bg_dark, fg = '#e0af68' } -- amber: modified in place
        hl.GitSignsDelete = { bg = c.bg_dark, fg = '#f7768e' } -- red

        -- Gitsigns line-number highlights (numhl)
        hl.GitSignsAddNr    = { bg = c.bg_dark, fg = '#73daca', bold = true }
        hl.GitSignsChangeNr = { bg = c.bg_dark, fg = '#e0af68', bold = true }
        hl.GitSignsDeleteNr = { bg = c.bg_dark, fg = '#f7768e', bold = true }

        -- Gitsigns line highlights (diff review mode: linehl=true)
        -- Green = new content (add/change/changedelete), Red = removed content
        -- Matches delta/fzf convention: new line is always green
        hl.GitSignsAddLn          = { bg = '#1a3020' } -- green: new line
        hl.GitSignsChangeLn       = { bg = '#1a3020' } -- green: current line is new content
        hl.GitSignsDeleteLn       = { bg = '#2d1a1a' } -- red: removed line (virtual)
        hl.GitSignsChangeDeleteLn = { bg = '#1a3020' } -- green: new content replacing deleted

        -- Gitsigns word-diff inline highlights
        hl.GitSignsAddInline    = { bg = '#1f4a2e', bold = true } -- stronger green for changed words
        hl.GitSignsChangeInline = { bg = '#1a3060', bold = true } -- stronger blue for changed words
        hl.GitSignsDeleteInline = { bg = '#4a1a1a', bold = true } -- stronger red for deleted words
      end,
    })

    -- Set colorscheme with error handling
    local ok, err = pcall(vim.cmd.colorscheme, 'tokyonight-night')
    if not ok then
      notify.warn('Tokyonight', 'Failed to load tokyonight-night: ' .. err)
      -- Fallback to default colorscheme
      vim.cmd.colorscheme('default')
    end

    -- Force solid backgrounds after colorscheme load (Tokyo Night hex values)
    vim.schedule(function()
      local bg = '#1a1b26'
      local bg_dark = '#16161e'
      vim.api.nvim_set_hl(0, 'Normal', { bg = bg })
      vim.api.nvim_set_hl(0, 'NormalNC', { bg = bg_dark })
      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = bg })
      vim.api.nvim_set_hl(0, 'SignColumn', { bg = bg_dark })
      vim.api.nvim_set_hl(0, 'LineNr', { bg = bg_dark })
      vim.api.nvim_set_hl(0, 'CursorLineNr', { bg = bg_dark })
      vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = bg })
      vim.api.nvim_set_hl(0, 'NonText', { bg = bg })
      vim.api.nvim_set_hl(0, 'VertSplit', { bg = bg_dark })
      vim.api.nvim_set_hl(0, 'WinSeparator', { bg = bg_dark })
      vim.api.nvim_set_hl(0, 'TabLine', { bg = bg_dark })
      vim.api.nvim_set_hl(0, 'TabLineFill', { bg = bg_dark })
      vim.api.nvim_set_hl(0, 'TabLineSel', { bg = bg_dark })
      vim.api.nvim_set_hl(0, 'StatusLine', { bg = bg_dark })
      vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = bg_dark })
      vim.api.nvim_set_hl(0, 'WinBar', { bg = bg_dark, fg = '#c0caf5' })
      vim.api.nvim_set_hl(0, 'WinBarNC', { bg = bg_dark, fg = '#565f89' })
      vim.api.nvim_set_hl(0, 'FoldColumn', { bg = bg_dark })
      vim.api.nvim_set_hl(0, 'Folded', { bg = bg_dark })
      vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#3d59a1' })
      vim.api.nvim_set_hl(0, 'CursorColumn', { bg = '#3d59a1' })

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

      vim.api.nvim_set_hl(0, 'DiagnosticSignError', { bg = bg_dark, fg = '#f7768e' })
      vim.api.nvim_set_hl(0, 'DiagnosticSignWarn', { bg = bg_dark, fg = '#e0af68' })
      vim.api.nvim_set_hl(0, 'DiagnosticSignInfo', { bg = bg_dark, fg = '#0db9d7' })
      vim.api.nvim_set_hl(0, 'DiagnosticSignHint', { bg = bg_dark, fg = '#1abc9c' })
      vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextWarn', {
        bg = bg_dark,
        fg = '#e0af68',
        italic = true,
      })
      vim.api.nvim_set_hl(0, 'GitSignsAdd',    { bg = bg_dark, fg = '#73daca' })
      vim.api.nvim_set_hl(0, 'GitSignsChange', { bg = bg_dark, fg = '#e0af68' })
      vim.api.nvim_set_hl(0, 'GitSignsDelete', { bg = bg_dark, fg = '#f7768e' })
      vim.api.nvim_set_hl(0, 'GitSignsAddNr',    { bg = bg_dark, fg = '#73daca', bold = true })
      vim.api.nvim_set_hl(0, 'GitSignsChangeNr', { bg = bg_dark, fg = '#e0af68', bold = true })
      vim.api.nvim_set_hl(0, 'GitSignsDeleteNr', { bg = bg_dark, fg = '#f7768e', bold = true })
      vim.api.nvim_set_hl(0, 'GitSignsAddLn',          { bg = '#1a3020' })
      vim.api.nvim_set_hl(0, 'GitSignsChangeLn',       { bg = '#1a3020' })
      vim.api.nvim_set_hl(0, 'GitSignsDeleteLn',       { bg = '#2d1a1a' })
      vim.api.nvim_set_hl(0, 'GitSignsChangeDeleteLn', { bg = '#1a3020' })
      vim.api.nvim_set_hl(0, 'GitSignsAddInline',    { bg = '#1f4a2e', bold = true })
      vim.api.nvim_set_hl(0, 'GitSignsChangeInline', { bg = '#1a3060', bold = true })
      vim.api.nvim_set_hl(0, 'GitSignsDeleteInline', { bg = '#4a1a1a', bold = true })
    end)
  end,
}
