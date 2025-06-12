-- Modern chunk highlighting with rounded corners - discrete yet stylish
return {
  'shellRaining/hlchunk.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('hlchunk').setup({
      chunk = {
        enable = true,
        priority = 15,
        style = { {
          fg = '#565f89',
        } },
        use_treesitter = true,
        chars = {
          horizontal_line = '─',
          vertical_line = '│',
          left_top = '╭', -- Rounded corners for modern look
          left_bottom = '╰', -- Rounded corners for modern look
          right_arrow = '▶', -- Modern arrow for better visual flow
        },
        textobject = '',
        max_file_size = 1024 * 1024,
        error_sign = false,
        duration = 150, -- Subtle animation for modern feel
        delay = 50,
      },
      indent = {
        enable = true,
        priority = 10,
        style = {
          {
            fg = '#3b4261',
          }, -- More visible but still subtle
        },
        use_treesitter = false,
        chars = { '┃' }, -- Slightly thicker line for better visibility
        ahead_lines = 5,
        delay = 0,
      },
      line_num = {
        enable = false,
      },
      blank = {
        enable = false,
      },
    })
  end,
}
