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
        close = function() require('trouble').close('diagnostics') end,
        is_open = function() return require('trouble').is_open('diagnostics') end,
        global_var = 'current_trouble_mode',
        refresh_cmd = 'redrawstatus',
      },
      loclist = {
        open = function(opts) require('trouble').open('loclist', opts) end,
        toggle = function(opts) require('trouble').toggle('loclist', opts) end,
        close = function() require('trouble').close('loclist') end,
        is_open = function() return require('trouble').is_open('loclist') end,
        global_var = 'current_trouble_mode',
        refresh_cmd = 'redrawstatus',
      },
      qflist = {
        open = function(opts) require('trouble').open('qflist', opts) end,
        toggle = function(opts) require('trouble').toggle('qflist', opts) end,
        close = function() require('trouble').close('qflist') end,
        is_open = function() return require('trouble').is_open('qflist') end,
        global_var = 'current_trouble_mode',
        refresh_cmd = 'redrawstatus',
      },
      lsp_references = {
        open = function(opts) require('trouble').open('lsp_references', opts) end,
        toggle = function(opts) require('trouble').toggle('lsp_references', opts) end,
        close = function() require('trouble').close('lsp_references') end,
        is_open = function() return require('trouble').is_open('lsp_references') end,
        global_var = 'current_trouble_mode',
        refresh_cmd = 'redrawstatus',
      },
      symbols = {
        open = function(opts) require('trouble').open('symbols', opts) end,
        toggle = function(opts) require('trouble').toggle('symbols', opts) end,
        close = function() require('trouble').close('symbols') end,
        is_open = function() return require('trouble').is_open('symbols') end,
        global_var = 'current_trouble_mode',
        refresh_cmd = 'redrawstatus',
      },
      lsp_document_symbols = {
        open = function(opts) require('trouble').open('lsp_document_symbols', opts) end,
        toggle = function(opts) require('trouble').toggle('lsp_document_symbols', opts) end,
        close = function() require('trouble').close('lsp_document_symbols') end,
        is_open = function() return require('trouble').is_open('lsp_document_symbols') end,
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
        desc = 'Location list',
      },
      {
        '<leader>xw',
        trouble_manager.keymap('diagnostics'),
        desc = 'Workspace problems',
      },
      {
        '<leader>xq',
        trouble_manager.keymap('qflist'),
        desc = 'Quickfix list',
      },
      {
        '<leader>xr',
        trouble_manager.keymap('lsp_references'),
        desc = 'LSP references',
      },
      {
        '<F10>',
        trouble_manager.keymap('diagnostics'),
        desc = 'Toggle diagnostics',
      },
      {
        '<leader>xs',
        trouble_manager.keymap('symbols'),
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>xL',
        trouble_manager.keymap('loclist'),
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        trouble_manager.keymap('qflist'),
        desc = 'Quickfix List (Trouble)',
      },
      {
        '<leader>xS',
        trouble_manager.keymap('lsp_document_symbols'),
        desc = 'Document symbols',
      },
    }
  end,
  opts = {
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
    highlight = {
      groups = {
        TroublePreview = {
          bg = '#3b4261',
          fg = '#c0caf5',
        },
      },
    },
  },
  config = function(_, opts)
    require('trouble').setup(opts)

    -- Initialize global trouble mode tracking
    _G.current_trouble_mode = nil

    -- Prevent "No mode specified" spam from restored trouble panels
    local trouble_notify_filter = {}
    local original_notify = vim.notify
    vim.notify = function(msg, level, opts_inner)
      -- Suppress repeated "No mode specified" messages from trouble plugin
      if type(msg) == 'string' and msg:match('No mode specified') then
        local current_time = vim.fn.reltime()
        local msg_key = 'trouble_no_mode'

        -- Only allow this message once every 5 seconds
        if trouble_notify_filter[msg_key] then
          local elapsed = vim.fn.reltimefloat(vim.fn.reltime(trouble_notify_filter[msg_key]))
          if elapsed < 5.0 then
            return -- Suppress repeated message
          end
        end

        trouble_notify_filter[msg_key] = current_time
      end

      return original_notify(msg, level, opts_inner)
    end
  end,
}
