-- Onedark theme setup
return {
  'navarasu/onedark.nvim',
  priority = 1000,
  config = function()
    require('onedark').setup({
      style = 'darker',
      highlights = {
        -- Fix git tool visibility issues
        -- Make selected/cursor lines more visible in git tools
        CursorLine = {
          bg = '#2c323c',
        },
        Visual = {
          bg = '#3e4452',
        },

        -- Neogit specific highlights for better visibility
        NeogitDiffContext = {
          fg = '#abb2bf',
          bg = 'NONE',
        },
        NeogitDiffContextHighlight = {
          fg = '#abb2bf',
          bg = '#2c323c',
        },
        NeogitHunkHeader = {
          fg = '#56b6c2',
          bg = '#2c323c',
          style = 'bold',
        },
        NeogitHunkHeaderHighlight = {
          fg = '#56b6c2',
          bg = '#3e4452',
          style = 'bold',
        },
        NeogitDiffAdd = {
          fg = '#98c379',
          bg = 'NONE',
        },
        NeogitDiffAddHighlight = {
          fg = '#98c379',
          bg = '#2c323c',
        },
        NeogitDiffDelete = {
          fg = '#e06c75',
          bg = 'NONE',
        },
        NeogitDiffDeleteHighlight = {
          fg = '#e06c75',
          bg = '#2c323c',
        },

        -- Lazygit floating window improvements
        FloatBorder = {
          fg = '#56b6c2',
          bg = 'NONE',
        },
        NormalFloat = {
          fg = '#abb2bf',
          bg = '#1e222a',
        },

        -- Improve contrast for selected items in pickers/menus
        PmenuSel = {
          fg = '#282c34',
          bg = '#61afef',
          style = 'bold',
        },
        WildMenu = {
          fg = '#282c34',
          bg = '#61afef',
          style = 'bold',
        },
      },
    })
    vim.cmd.colorscheme('onedark')

    -- Additional highlight fixes that need to be applied after colorscheme
    vim.schedule(function()
      -- Force override for better git tool visibility
      vim.api.nvim_set_hl(0, 'CursorLine', {
        bg = '#2c323c',
      })
      vim.api.nvim_set_hl(0, 'Visual', {
        bg = '#3e4452',
      })

      -- Ensure selected items are clearly visible
      vim.api.nvim_set_hl(0, 'PmenuSel', {
        fg = '#282c34',
        bg = '#61afef',
        bold = true,
      })
      vim.api.nvim_set_hl(0, 'WildMenu', {
        fg = '#282c34',
        bg = '#61afef',
        bold = true,
      })
    end)
  end,
}
