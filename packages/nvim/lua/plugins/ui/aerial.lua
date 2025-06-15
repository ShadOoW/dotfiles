-- Aerial: A modern code outline window with better UI/UX than tagbar
return {
  'stevearc/aerial.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons', -- optional
  },
  config = function()
    local aerial = require('aerial')

    aerial.setup({
      -- Priority list of preferred backends for aerial
      backends = { 'treesitter', 'lsp', 'markdown', 'man' },

      -- UI Configuration
      layout = {
        max_width = { 40, 0.2 },
        width = nil,
        min_width = 10,
        win_opts = {},
        default_direction = 'left',
        placement = 'window',
        preserve_equality = false,
      },

      -- Attach to different filetypes
      attach_mode = 'window',
      close_automatic_events = {},

      -- Buffer awareness configuration
      -- Disable automatic opening, we'll handle this manually
      open_automatic = false,

      -- Keymaps
      keymaps = {
        ['?'] = 'actions.show_help',
        ['g?'] = 'actions.show_help',
        ['<CR>'] = 'actions.jump',
        ['<2-LeftMouse>'] = 'actions.jump',
        ['<C-v>'] = 'actions.jump_vsplit',
        ['<C-s>'] = 'actions.jump_split',
        ['p'] = 'actions.scroll',
        ['<C-j>'] = 'actions.down_and_scroll',
        ['<C-k>'] = 'actions.up_and_scroll',
        ['{'] = 'actions.prev',
        ['}'] = 'actions.next',
        ['[['] = 'actions.prev_up',
        [']]'] = 'actions.next_up',
        ['q'] = 'actions.close',
        ['o'] = 'actions.tree_toggle',
        ['za'] = 'actions.tree_toggle',
        ['O'] = 'actions.tree_toggle_recursive',
        ['zA'] = 'actions.tree_toggle_recursive',
        ['l'] = 'actions.tree_open',
        ['zo'] = 'actions.tree_open',
        ['L'] = 'actions.tree_open_recursive',
        ['zO'] = 'actions.tree_open_recursive',
        ['h'] = 'actions.tree_close',
        ['zc'] = 'actions.tree_close',
        ['H'] = 'actions.tree_close_recursive',
        ['zC'] = 'actions.tree_close_recursive',
        ['zr'] = 'actions.tree_increase_fold_level',
        ['zR'] = 'actions.tree_open_all',
        ['zm'] = 'actions.tree_decrease_fold_level',
        ['zM'] = 'actions.tree_close_all',
        ['zx'] = 'actions.tree_sync_folds',
        ['zX'] = 'actions.tree_sync_folds',
      },

      -- Disable on certain filetypes
      disable_max_lines = 10000,
      disable_max_size = 2000000, -- 2MB

      -- Filter configuration
      filter_kind = {
        'Array',
        'Boolean',
        'Class',
        'Constant',
        'Constructor',
        'Enum',
        'Field',
        'File',
        'Function',
        'Interface',
        'Key',
        'Method',
        'Module',
        'Namespace',
        'Null',
        'Number',
        'Object',
        'Package',
        'Property',
        'String',
        'Struct',
        'TypeParameter',
        'Variable',
      },

      -- Highlight configuration
      highlight_mode = 'split_width',
      highlight_closest = true,
      highlight_on_hover = false,
      highlight_on_jump = 300,

      -- Auto jump configuration
      autojump = true,

      -- Icons and formatting
      icons = {},

      -- Show box drawing characters for guides
      show_guides = true,

      -- Customize the guides (requires nvim 0.10+)
      guides = {
        mid_item = '├─',
        last_item = '└─',
        nested_top = '│ ',
        whitespace = '  ',
      },

      -- Floating window configuration
      float = {
        border = 'rounded',
        relative = 'cursor',
        max_height = 0.9,
        height = nil,
        min_height = { 8, 0.1 },
      },

      -- LSP symbol kinds to ignore
      ignore = {
        unlisted_buffers = false,
        diff_windows = true,
        filetypes = {},
        buftypes = 'special',
        wintypes = 'special',
      },

      -- Manage aerial windows
      manage_folds = true,
      link_folds_to_tree = false,
      link_tree_to_folds = true,

      -- Fold text customization
      nerd_font = 'auto',

      -- Post parse symbol callback
      on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', {
          buffer = bufnr,
        })
        vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', {
          buffer = bufnr,
        })
      end,

      -- Close aerial when you leave the original buffer
      close_on_select = false,

      -- Update symbol list on buffer changes
      update_events = 'TextChanged,InsertLeave,BufEnter,BufWritePost',

      -- Show symbols even if there are errors
      show_guides = true,

      -- Treesitter specific options
      treesitter = {
        update_delay = 300,
      },

      -- LSP specific options
      lsp = {
        diagnostics_trigger_update = true,
        update_when_errors = true,
        update_delay = 300,
      },
    })

    -- Buffer awareness setup
    local aerial_group = vim.api.nvim_create_augroup('AerialBufferAware', {
      clear = true,
    })

    -- Auto-update aerial when switching buffers
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
      group = aerial_group,
      callback = function(args)
        -- Only update if aerial is open
        if aerial.is_open() then
          -- Small delay to ensure buffer is fully loaded
          vim.defer_fn(function()
            -- Force refresh aerial for current buffer with error handling
            pcall(function() aerial.sync_load(args.buf) end)
          end, 50)
        end
      end,
      desc = 'Update aerial when switching buffers',
    })

    -- Auto-close aerial if switching to unsupported buffer types
    vim.api.nvim_create_autocmd('BufEnter', {
      group = aerial_group,
      callback = function(args)
        local buftype = vim.api.nvim_buf_get_option(args.buf, 'buftype')
        local filetype = vim.api.nvim_buf_get_option(args.buf, 'filetype')

        -- Close aerial for special buffer types
        if buftype ~= '' or filetype == 'help' or filetype == 'man' then
          if aerial.is_open() then aerial.close() end
        end
      end,
      desc = 'Close aerial for special buffer types',
    })

    -- Buffer-aware toggle function
    vim.keymap.set('n', '<leader>pa', function() require('aerial').toggle() end, {
      desc = 'Toggle Aerial Panel',
    })
  end,
}
