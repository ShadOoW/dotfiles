-- Enhanced scrollbar with tokyo night colors
return {
  'petertriho/nvim-scrollbar',
  dependencies = { 'kevinhwang91/nvim-hlslens' },
  event = 'BufReadPost',
  config = function()
    require('scrollbar').setup({
      show = true,
      handle = {
        text = ' ',
        color = '#3b4261',
        hide_if_all_visible = true,
      },
      marks = {
        Search = {
          color = '#ff9e64',
        },
        Error = {
          color = '#db4b4b',
        },
        Warn = {
          color = '#e0af68',
        },
        Info = {
          color = '#0db9d7',
        },
        Hint = {
          color = '#1abc9c',
        },
        Misc = {
          color = '#9d7cd8',
        },
      },
      handlers = {
        cursor = true,
        diagnostic = true,
        gitsigns = true,
        handle = true,
        search = true,
      },
      excluded_buftypes = { 'terminal', 'prompt', 'nofile' },
      excluded_filetypes = { 'prompt', 'TelescopePrompt', 'noice', 'notify' },
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
      },
      hide_if_all_visible = true,
      show_in_active_only = false,
      position = 'left', -- Show scrollbar on the left
    })
  end,
}
