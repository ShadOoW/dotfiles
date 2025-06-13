-- Enhanced scrollbar with tokyo night colors
return {
  'petertriho/nvim-scrollbar',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    local colors = require('tokyonight.colors').setup()

    require('scrollbar').setup({
      show = true,
      show_in_active_only = false,
      set_highlights = true,
      folds = 1000, -- handle folds
      max_lines = false, -- disables if number of lines in buffer is higher
      handle = {
        text = ' ',
        color = colors.fg_gutter,
        color_nr = nil, -- cterm
        highlight = 'CursorColumn',
        hide_if_all_visible = true, -- Hides handle if all lines are visible
      },
      marks = {
        Search = {
          text = { '-', '=' },
          priority = 0,
          color = colors.orange,
          highlight = 'Search',
        },
        Error = {
          text = { '-', '=' },
          priority = 1,
          color = colors.error,
          highlight = 'DiagnosticVirtualTextError',
        },
        Warn = {
          text = { '-', '=' },
          priority = 2,
          color = colors.warning,
          highlight = 'DiagnosticVirtualTextWarn',
        },
        Info = {
          text = { '-', '=' },
          priority = 3,
          color = colors.info,
          highlight = 'DiagnosticVirtualTextInfo',
        },
        Hint = {
          text = { '-', '=' },
          priority = 4,
          color = colors.hint,
          highlight = 'DiagnosticVirtualTextHint',
        },
        Misc = {
          text = { '-', '=' },
          priority = 5,
          color = colors.purple,
          highlight = 'Normal',
        },
        GitAdd = {
          text = '┆',
          priority = 7,
          color = colors.git.add,
          highlight = 'GitSignsAdd',
        },
        GitChange = {
          text = '┆',
          priority = 7,
          color = colors.git.change,
          highlight = 'GitSignsChange',
        },
        GitDelete = {
          text = '▁',
          priority = 7,
          color = colors.git.delete,
          highlight = 'GitSignsDelete',
        },
      },
      excluded_buftypes = { 'terminal', 'nofile', 'quickfix', 'prompt' },
      excluded_filetypes = {
        'cmp_docs',
        'cmp_menu',
        'noice',
        'prompt',
        'TelescopePrompt',
        'neo-tree',
        'Trouble',
        'trouble',
        'lazy',
        'mason',
        'notify',
        'toggleterm',
        'lazyterm',
      },
      autocmd = {
        render = {
          'BufWinEnter',
          'TabEnter',
          'TermEnter',
          'WinEnter',
          'CmdwinLeave',
          'TextChanged',
          'VimResized',
          'WinScrolled',
        },
        clear = { 'BufWinLeave', 'TabLeave', 'TermLeave', 'WinLeave' },
      },
      handlers = {
        cursor = true,
        diagnostic = true,
        gitsigns = true, -- Requires gitsigns
        handle = true,
        search = true, -- Requires hlslens
        ale = false, -- Requires ALE
      },
    })
  end,
}
