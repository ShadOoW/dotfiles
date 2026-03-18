-- When trouble is already open, let it handle mode-switching/closing itself.
-- When trouble is closed, open via panel-manager so competing panels (noice,
-- output-panel) are closed first.
local function trouble_toggle(mode)
  local trouble = require('trouble')
  if trouble.is_open() then
    trouble.toggle(mode)
  else
    require('plugins.ui.panel-manager').open_with('trouble', function()
      trouble.open(mode)
    end)
  end
end

return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = { 'Trouble' },
  keys = {
    { '<F10>', function() trouble_toggle('diagnostics') end, desc = 'Trouble - Diagnostics' },
    { '<leader>xl', function() trouble_toggle('loclist') end, desc = 'Trouble - Location list' },
    { '<leader>xr', function() trouble_toggle('lsp_references') end, desc = 'Trouble - LSP references' },
    { '<leader>xs', function() trouble_toggle('symbols') end, desc = 'Trouble - Symbols' },
    { '<leader>xS', function() trouble_toggle('lsp_document_symbols') end, desc = 'Trouble - Document symbols' },
  },
  opts = {
    modes = {
      qflist = {
        follow = false,
      },
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
    auto_close = false,
    auto_open = false,
    auto_preview = true,
    auto_refresh = true,
    focus = true,
    restore = true,
    follow = true,
    indent_guides = true,
    multiline = true,
    pinned = false,
    win = {
      size = {
        height = 12,
      },
      border = 'rounded',
    },
    preview = {
      type = 'main',
      scratch = true,
    },
    throttle = {
      refresh = 200,
      update = 10,
      render = 10,
      follow = 100,
      preview = {
        ms = 100,
        debounce = true,
      },
    },
    actions = {},
    keys = {
      ['?'] = 'help',
      ['r'] = 'refresh',
      ['R'] = 'toggle_refresh',
      ['q'] = 'close',
      ['<esc>'] = 'cancel',
      ['<cr>'] = 'jump',
      ['<2-leftmouse>'] = 'jump',
      ['<c-s>'] = 'jump_split',
      ['<c-v>'] = 'jump_vsplit',
      ['j'] = 'next',
      ['k'] = 'prev',
      ['<down>'] = 'next',
      ['<up>'] = 'prev',
      ['}'] = 'next',
      ['{'] = 'prev',
      ['[['] = 'prev',
      [']]'] = 'next',
      ['dd'] = 'delete',
      ['d'] = { action = 'delete', mode = 'v' },
      ['i'] = 'inspect',
      ['p'] = 'preview',
      ['P'] = 'toggle_preview',
      ['zo'] = 'fold_open',
      ['zO'] = 'fold_open_recursive',
      ['zc'] = 'fold_close',
      ['zC'] = 'fold_close_recursive',
      ['za'] = 'fold_toggle',
      ['zA'] = 'fold_toggle_recursive',
      ['zm'] = 'fold_more',
      ['zM'] = 'fold_close_all',
      ['zr'] = 'fold_reduce',
      ['zR'] = 'fold_open_all',
      ['zx'] = 'fold_update',
      ['zX'] = 'fold_update_all',
      ['zn'] = 'fold_disable',
      ['zN'] = 'fold_enable',
      ['zi'] = 'fold_toggle_enable',
    },
    icons = {
      indent = {
        top = '│ ',
        middle = '├╴',
        last = '└╴',
        fold_open = ' ',
        fold_closed = ' ',
        ws = '  ',
      },
      folder_closed = ' ',
      folder_open = ' ',
      kinds = {
        Array = ' ',
        Boolean = '󰨙 ',
        Class = ' ',
        Constant = '󰏿 ',
        Constructor = ' ',
        Enum = ' ',
        EnumMember = ' ',
        Event = ' ',
        Field = ' ',
        File = ' ',
        Function = '󰊕 ',
        Interface = ' ',
        Key = ' ',
        Method = '󰊕 ',
        Module = ' ',
        Namespace = '󰦮 ',
        Null = ' ',
        Number = '󰎠 ',
        Object = ' ',
        Operator = ' ',
        Package = ' ',
        Property = ' ',
        String = ' ',
        Struct = '󰆼 ',
        TypeParameter = ' ',
        Variable = '󰀫 ',
      },
    },
  },
  config = function(_, opts)
    require('trouble').setup(opts)

    -- Track current trouble mode for lualine display
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'trouble',
      callback = function()
        local view = require('trouble.view')
        if view and view.current then _G.current_trouble_mode = view.current.mode end
      end,
    })
  end,
}
