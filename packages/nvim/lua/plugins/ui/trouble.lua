return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = { 'Trouble' },
  keys = {
    {
      '<leader>xx',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Toggle trouble diagnostics',
    },
    {
      '<leader>xw',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Workspace diagnostics',
    },
    {
      '<leader>xd',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Document diagnostics',
    },
    {
      '<leader>xl',
      '<cmd>Trouble loclist toggle<cr>',
      desc = 'Location list',
    },
    {
      '<leader>xq',
      '<cmd>Trouble qflist toggle<cr>',
      desc = 'Quickfix list',
    },
    {
      '<leader>xr',
      '<cmd>Trouble lsp toggle<cr>',
      desc = 'LSP references',
    },
    {
      '<F10>',
      '<cmd>Trouble diagnostics toggle<CR>',
      desc = 'Toggle diagnostics',
    },
    {
      '<leader>xs',
      '<cmd>Trouble symbols toggle focus=false<cr>',
      desc = 'Symbols (Trouble)',
    },
    {
      '<leader>xL',
      '<cmd>Trouble loclist toggle<cr>',
      desc = 'Location List (Trouble)',
    },
    {
      '<leader>xQ',
      '<cmd>Trouble qflist toggle<cr>',
      desc = 'Quickfix List (Trouble)',
    },
  },
  config = function()
    require('trouble').setup({
      modes = {
        preview_float = {
          mode = 'diagnostics',
          preview = {
            type = 'float',
            relative = 'editor',
            border = 'rounded',
            title = 'Preview',
            title_pos = 'center',
            position = { 0, -2 },
            size = {
              width = 0.3,
              height = 0.3,
            },
            zindex = 200,
          },
        },
      },
    })
  end,
}
