return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = { 'Trouble' },
  opts = {
    modes = {
      -- Shows only the most severe diagnostic level present.
      -- As errors are fixed, warnings surface automatically.
      cascade = {
        mode = 'diagnostics',
        filter = function(items)
          local severity = vim.diagnostic.severity.HINT
          for _, item in ipairs(items) do
            severity = math.min(severity, item.severity)
          end
          return vim.tbl_filter(function(i) return i.severity == severity end, items)
        end,
      },
      qflist = {
        follow = false,
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
      size = { height = 12 },
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
      preview = { ms = 100, debounce = true },
    },
    keys = {
      ['?'] = 'help',
      ['r'] = 'refresh',
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
      -- Cycle severity filter: all → error → warn → all
      ['s'] = {
        action = function(view)
          local f = view:get_filter('severity')
          local current = f and f.filter.severity
          if not current then
            view:filter({ severity = vim.diagnostic.severity.ERROR }, { id = 'severity' })
          elseif current == vim.diagnostic.severity.ERROR then
            view:filter({ severity = vim.diagnostic.severity.WARN }, { id = 'severity' })
          else
            view:filter(nil, { id = 'severity', del = true })
          end
        end,
        desc = 'Cycle severity filter (all → error → warn → all)',
      },
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
