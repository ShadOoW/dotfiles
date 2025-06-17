-- Modern bracket/parentheses highlighting with rainbow colors
return {
  {
    'HiPhish/rainbow-delimiters.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local rainbow_delimiters = require('rainbow-delimiters')

      -- Setup rainbow delimiters with Tokyo Night colors
      vim.g.rainbow_delimiters = {
        strategy = {
          [''] = rainbow_delimiters.strategy['global'],
          vim = rainbow_delimiters.strategy['local'],
        },
        query = {
          [''] = 'rainbow-delimiters',
          lua = 'rainbow-blocks',
        },
        priority = {
          [''] = 110,
          lua = 210,
        },
        highlight = {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterViolet',
          'RainbowDelimiterCyan',
        },
      }

      -- Set up Tokyo Night inspired colors for rainbow delimiters
      local colors = {
        red = '#f7768e',
        yellow = '#e0af68',
        blue = '#7aa2f7',
        orange = '#ff9e64',
        green = '#9ece6a',
        violet = '#bb9af7',
        cyan = '#7dcfff',
      }

      -- Apply the colors
      vim.api.nvim_set_hl(0, 'RainbowDelimiterRed', {
        fg = colors.red,
      })
      vim.api.nvim_set_hl(0, 'RainbowDelimiterYellow', {
        fg = colors.yellow,
      })
      vim.api.nvim_set_hl(0, 'RainbowDelimiterBlue', {
        fg = colors.blue,
      })
      vim.api.nvim_set_hl(0, 'RainbowDelimiterOrange', {
        fg = colors.orange,
      })
      vim.api.nvim_set_hl(0, 'RainbowDelimiterGreen', {
        fg = colors.green,
      })
      vim.api.nvim_set_hl(0, 'RainbowDelimiterViolet', {
        fg = colors.violet,
      })
      vim.api.nvim_set_hl(0, 'RainbowDelimiterCyan', {
        fg = colors.cyan,
      })
    end,
  },
  {
    'andymass/vim-matchup',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      -- Enhanced matching for brackets, parentheses, and more
      vim.g.matchup_matchparen_offscreen = {
        method = 'popup',
      }
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_hi_surround_always = 1

      -- Disable default matchparen since we're using matchup
      vim.g.loaded_matchparen = 1

      -- Custom highlight for matching pairs
      vim.api.nvim_set_hl(0, 'MatchParen', {
        bg = '#414868',
        fg = '#c0caf5',
        bold = true,
      })

      -- Highlight for off-screen matches
      vim.api.nvim_set_hl(0, 'MatchParenCur', {
        bg = '#414868',
        fg = '#7aa2f7',
        bold = true,
      })

      -- Configure which pairs to match
      vim.g.matchup_matchparen_enabled = 1
      vim.g.matchup_motion_enabled = 1
      vim.g.matchup_text_obj_enabled = 1
    end,
  },
}
