-- Grug Far - Find and replace with multiline support
return {
  'MagicDuck/grug-far.nvim',
  config = function()
    require('grug-far').setup({
      -- Keybindings for find and replace buffer
      keymaps = {
        replace = {
          n = '<leader>mr',
        },
        qflist = {
          n = '<leader>mq',
        },
        syncLocations = {
          n = '<leader>ms',
        },
        syncLine = {
          n = '<leader>ml',
        },
        close = {
          n = '<leader>mc',
        },
        historyOpen = {
          n = '<leader>mt',
        },
        historyAdd = {
          n = '<leader>ma',
        },
        refresh = {
          n = '<leader>mf',
        },
        openLocation = {
          n = '<leader>mo',
        },
        openNextLocation = {
          n = '<down>',
        },
        openPrevLocation = {
          n = '<up>',
        },
        gotoLocation = {
          n = '<enter>',
        },
        pickHistoryEntry = {
          n = '<enter>',
        },
        abort = {
          n = '<leader>mb',
        },
        help = {
          n = 'g?',
        },
        toggleShowCommand = {
          n = '<leader>mp',
        },
        swapEngine = {
          n = '<leader>me',
        },
      },
      -- Static title
      windowCreationCommand = 'vsplit',
      -- Min search chars before auto searching
      minSearchChars = 2,
      -- Max search chars before showing warning
      maxSearchChars = 2000,
      -- Max results to show
      maxWorkerCount = 4,
      -- Icons
      icons = {
        enabled = true,
        actionEntryBullet = '  ',
      },
      -- Engine settings
      engines = {
        ripgrep = {
          -- Show line numbers
          showReplaceDiff = true,
        },
      },
      -- Folding config
      folding = {
        enabled = true,
        foldlevel = 99,
      },
      -- Results display
      resultsHighlight = true,
      -- Wrap text
      wrap = true,
      -- Transient buffer options
      transient = false,
    })

    -- Keymaps for launching grug-far
    vim.keymap.set(
      'n',
      '<leader>mr',
      function()
        require('grug-far').open({
          transient = true,
        })
      end,
      {
        desc = 'Search and Replace',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>mR',
      function()
        require('grug-far').open({
          transient = true,
          prefills = {
            search = vim.fn.expand('<cword>'),
          },
        })
      end,
      {
        desc = 'Search and Replace (current word)',
      }
    )

    vim.keymap.set(
      'v',
      '<leader>mr',
      function()
        require('grug-far').with_visual_selection({
          transient = true,
        })
      end,
      {
        desc = 'Search and Replace (visual selection)',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>mf',
      function()
        require('grug-far').open({
          transient = true,
          prefills = {
            paths = vim.fn.expand('%'),
          },
        })
      end,
      {
        desc = 'Search and Replace in current file',
      }
    )
  end,
}
