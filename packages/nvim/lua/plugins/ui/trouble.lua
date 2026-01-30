return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = { 'Trouble' },
  keys = function()
    local panel_manager = require('utils.panel-manager')

    -- Create trouble panel configurations
    local trouble_panels = {
      diagnostics = {
        open = function(opts) require('trouble').open('diagnostics', opts) end,
        toggle = function(opts) require('trouble').toggle('diagnostics', opts) end,
        close = function() require('trouble').close() end,
        is_open = function() return require('trouble').is_open() end,
        global_var = 'current_trouble_mode',
        refresh_cmd = 'redrawstatus',
      },
      loclist = {
        open = function(opts) require('trouble').open('loclist', opts) end,
        toggle = function(opts) require('trouble').toggle('loclist', opts) end,
        close = function() require('trouble').close() end,
        is_open = function() return require('trouble').is_open() end,
        global_var = 'current_trouble_mode',
        refresh_cmd = 'redrawstatus',
      },
      qflist = {
        open = function(opts) require('trouble').open('qflist', opts) end,
        toggle = function(opts) require('trouble').toggle('qflist', opts) end,
        close = function() require('trouble').close() end,
        is_open = function() return require('trouble').is_open() end,
        global_var = 'current_trouble_mode',
        refresh_cmd = 'redrawstatus',
      },
      lsp_references = {
        open = function(opts) require('trouble').open('lsp_references', opts) end,
        toggle = function(opts) require('trouble').toggle('lsp_references', opts) end,
        close = function() require('trouble').close() end,
        is_open = function() return require('trouble').is_open() end,
        global_var = 'current_trouble_mode',
        refresh_cmd = 'redrawstatus',
      },
      symbols = {
        open = function(opts) require('trouble').open('symbols', opts) end,
        toggle = function(opts) require('trouble').toggle('symbols', opts) end,
        close = function() require('trouble').close() end,
        is_open = function() return require('trouble').is_open() end,
        global_var = 'current_trouble_mode',
        refresh_cmd = 'redrawstatus',
      },
      lsp_document_symbols = {
        open = function(opts) require('trouble').open('lsp_document_symbols', opts) end,
        toggle = function(opts) require('trouble').toggle('lsp_document_symbols', opts) end,
        close = function() require('trouble').close() end,
        is_open = function() return require('trouble').is_open() end,
        global_var = 'current_trouble_mode',
        refresh_cmd = 'redrawstatus',
      },
    }

    -- Create exclusive panel manager
    local trouble_manager = panel_manager.create_exclusive_group('trouble', trouble_panels)

    return {
      {
        '<leader>xl',
        trouble_manager.keymap('loclist'),
        desc = 'Trouble - Location list',
      },
      {
        '<leader>xw',
        trouble_manager.keymap('diagnostics'),
        desc = 'Trouble - Workspace problems',
      },
      {
        '<leader>xc',
        trouble_manager.keymap('qflist'),
        desc = 'Trouble - Quickfix list',
      },
      {
        '<leader>xr',
        trouble_manager.keymap('lsp_references'),
        desc = 'Trouble - LSP references',
      },
      {
        '<F10>',
        trouble_manager.keymap('diagnostics'),
        desc = 'Trouble - Toggle diagnostics',
      },
      {
        '<leader>xs',
        trouble_manager.keymap('symbols'),
        desc = 'Trouble - Symbols',
      },
      {
        '<leader>xS',
        trouble_manager.keymap('lsp_document_symbols'),
        desc = 'Trouble - Document symbols',
      },
    }
  end,
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
      ['d'] = {
        action = 'delete',
        mode = 'v',
      },
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

    -- Initialize global trouble mode tracking
    _G.current_trouble_mode = nil

    -- Create an autocommand to track the current trouble mode
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'Trouble',
      callback = function()
        local view = require('trouble.view')
        if view and view.current then _G.current_trouble_mode = view.current.mode end
      end,
    })
  end,
}
