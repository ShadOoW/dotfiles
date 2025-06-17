-- Test runner framework
-- Provides a unified interface for running tests
return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/nvim-nio', -- Add other adapters as needed:
    -- 'nvim-neotest/neotest-python',
    -- 'nvim-neotest/neotest-plenary',
    -- 'nvim-neotest/neotest-vim-test',
  },
  keys = {
    {
      '<leader>tn',
      function() require('neotest').run.run() end,
      desc = 'Run Nearest Test',
    },
    {
      '<leader>tf',
      function() require('neotest').run.run(vim.fn.expand('%')) end,
      desc = 'Run File Tests',
    },
    {
      '<leader>tA',
      function() require('neotest').run.run(vim.fn.getcwd()) end,
      desc = 'Run All Tests',
    },
    {
      '<leader>ts',
      function() require('neotest').summary.toggle() end,
      desc = 'Toggle Test Summary',
    },
    {
      '<leader>to',
      function()
        require('neotest').output.open({
          enter = true,
          auto_close = true,
        })
      end,
      desc = 'Show Test Output',
    },
    {
      '<leader>tO',
      function() require('neotest').output_panel.toggle() end,
      desc = 'Toggle Test Output Panel',
    },
    {
      '<leader>tw',
      function() require('neotest').watch.toggle(vim.fn.expand('%')) end,
      desc = 'Toggle Test Watch',
    },
  },
  config = function()
    require('neotest').setup({
      adapters = {
        -- Add other adapters as needed:
        -- require('neotest-python'),
        -- require('neotest-plenary'),
        -- require('neotest-vim-test')({ ignore_file_types = { 'python', 'vim', 'lua' } }),
      },
      discovery = {
        enabled = true,
        concurrent = 1,
      },
      diagnostic = {
        enabled = true,
        severity = 1,
      },
      floating = {
        border = 'rounded',
        max_height = 0.6,
        max_width = 0.6,
        options = {},
      },
      highlights = {
        adapter_name = 'NeotestAdapterName',
        border = 'NeotestBorder',
        dir = 'NeotestDir',
        expand_marker = 'NeotestExpandMarker',
        failed = 'NeotestFailed',
        file = 'NeotestFile',
        focused = 'NeotestFocused',
        indent = 'NeotestIndent',
        marked = 'NeotestMarked',
        namespace = 'NeotestNamespace',
        passed = 'NeotestPassed',
        running = 'NeotestRunning',
        select_win = 'NeotestWinSelect',
        skipped = 'NeotestSkipped',
        target = 'NeotestTarget',
        test = 'NeotestTest',
        unknown = 'NeotestUnknown',
      },
      icons = {
        child_indent = '│',
        child_prefix = '├',
        collapsed = '─',
        expanded = '╮',
        failed = '✖',
        final_child_indent = ' ',
        final_child_prefix = '╰',
        non_collapsible = '─',
        passed = '✓',
        running = '●',
        running_animated = { '/', '|', '\\', '-', '/', '|', '\\', '-' },
        skipped = '○',
        unknown = '?',
        watching = '👁',
      },
      output = {
        enabled = true,
        open_on_run = 'short',
      },
      output_panel = {
        enabled = true,
        open = 'botright split | resize 15',
      },
      quickfix = {
        enabled = true,
        open = false,
      },
      run = {
        enabled = true,
      },
      running = {
        concurrent = true,
      },
      status = {
        enabled = true,
        signs = true,
        virtual_text = false,
      },
      strategies = {
        integrated = {
          height = 40,
          width = 120,
        },
      },
      summary = {
        enabled = true,
        animated = true,
        follow = true,
        expand_errors = true,
        mappings = {
          attach = 'a',
          clear_marked = 'M',
          clear_target = 'T',
          debug = 'd',
          debug_marked = 'D',
          expand = { '<CR>', '<2-LeftMouse>' },
          expand_all = 'e',
          help = '?',
          jumpto = 'i',
          mark = 'm',
          next_failed = 'J',
          output = 'o',
          prev_failed = 'K',
          run = 'r',
          run_marked = 'R',
          short = 'O',
          stop = 'u',
          target = 't',
          watch = 'w',
        },
        open = 'botright vsplit | vertical resize 50',
      },
    })
  end,
}
