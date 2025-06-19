-- Modern completion with blink.cmp
return {
  'saghen/blink.cmp',
  lazy = false,
  dependencies = { 'rafamadriz/friendly-snippets', 'Exafunction/codeium.nvim' },
  version = '*',
  build = 'cargo build --release',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' for mappings similar to built-in completion
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    -- See the "default configuration" section below for full documentation on overriding presets
    keymap = {
      preset = 'enter',

      -- Arrow key navigation (maintaining nvim-cmp behavior)
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },

      -- Ctrl navigation as alternative
      ['<C-k>'] = { 'select_prev', 'fallback' },
      ['<C-j>'] = { 'select_next', 'fallback' },

      -- Documentation scrolling
      ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },

      -- Snippet expansion and jumping
      ['<C-l>'] = { 'snippet_forward', 'fallback' },
      ['<S-k>'] = { 'snippet_backward', 'fallback' },

      -- For terminals that don't handle Ctrl+Space well
      ['<C-@>'] = { 'show', 'fallback' }, -- Ctrl+Space alternative in some terminals

      -- Close completion window
      ['<C-e>'] = { 'hide', 'fallback' },

      -- Only Enter confirms completion (don't auto-select first item)
      ['<CR>'] = { 'accept', 'fallback' },
    },

    appearance = {
      -- Sets the fallback highlight groups to nvim-cmp's highlight groups
      -- Useful for when your theme doesn't support blink.cmp
      -- Will be removed in a future release
      use_nvim_cmp_as_default = false,
      -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing and ensures icons are aligned
      nerd_font_variant = 'mono',

      -- Blink does not expose its default kind icons so you must copy them all (or set your custom ones) and add Copilot
      kind_icons = {
        Copilot = '󰚩',
        Text = '󰉿',
        Method = '󰊕',
        Function = '󰊕',
        Constructor = '󰒓',

        Field = '󰜢',
        Variable = '󰆦',
        Property = '󰖷',

        Class = '󱡠',
        Interface = '󱡠',
        Struct = '󱡠',
        Module = '󰅩',

        Unit = '󰪚',
        Value = '󰦨',
        Enum = '󰦨',
        EnumMember = '󰦨',

        Keyword = '󰻾',
        Constant = '󰏿',

        Snippet = '󱄽',
        Color = '󰏘',
        File = '󰈔',
        Reference = '󰬲',
        Folder = '󰉋',
        Event = '󱐋',
        Operator = '󰪚',
        TypeParameter = '󰬛',
      },
    },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      -- Enable cmdline completions with enhanced settings
      cmdline = function()
        local type = vim.fn.getcmdtype()
        if type == ':' then
          return { 'cmdline', 'path' }
        elseif type == '/' or type == '?' then
          return { 'buffer' }
        end
        return {}
      end,

      providers = {
        -- Command line completion
        cmdline = {
          name = 'Cmdline',
          module = 'blink.cmp.sources.cmdline',
          opts = {
            -- Enable fuzzy matching for commands
            fuzzy = true,
            -- Case insensitive matching
            case_sensitive = false,
            -- Show command descriptions
            show_descriptions = true,
          },
        },

        -- Dont show LuaLS require statements when lazydev has items
        lsp = {
          fallbacks = { 'lazydev' },
        },
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
        },

        -- Enhanced buffer source
        buffer = {
          name = 'Buffer',
          module = 'blink.cmp.sources.buffer',
          opts = {
            -- Get buffers from all open windows
            get_bufnrs = function() return vim.api.nvim_list_bufs() end,
          },
        },

        -- Path completion
        path = {
          name = 'Path',
          module = 'blink.cmp.sources.path',
          score_offset = -3,
          opts = {
            trailing_slash = false,
            label_trailing_slash = true,
            get_cwd = function(context) return vim.fn.expand(('#%d:p:h'):format(context.bufnr)) end,
            show_hidden_files_by_default = false,
          },
        },

        -- Snippets
        snippets = {
          name = 'Snippets',
          module = 'blink.cmp.sources.snippets',
          score_offset = -1,
          opts = {
            friendly_snippets = true,
            search_paths = { vim.fn.stdpath('config') .. '/snippets' },
            global_snippets = { 'all' },
            extended_filetypes = {},
            ignored_filetypes = {},
          },
        },
      },
    },

    completion = {
      accept = {
        -- Experimental auto-brackets support
        auto_brackets = {
          enabled = true,
        },
      },

      trigger = {
        -- Show completion menu automatically after typing
        show_on_insert_on_trigger_character = true,
        show_on_x_blocked_trigger_characters = { ' ', '\n', '\t' },
        -- Show completion when manually triggered
        show_in_snippet = true,
        -- Ensure manual triggering works
        show_on_keyword = true,
        show_on_trigger_character = true,
      },

      list = {
        -- Maximum number of items to show
        max_items = 200,
        -- Selection behavior - use table configuration
        selection = {
          preselect = true,
          auto_insert = false,
        },
      },

      menu = {
        enabled = true,
        min_width = 15,
        max_height = 10,
        border = 'none',
        winblend = 0,
        winhighlight = 'Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
        scrollbar = false,

        -- Controls how the completion items are rendered on the popup window
        draw = {
          -- Left and right padding, optionally { left, right } for different padding on each side
          padding = 1,

          -- Gap between columns
          gap = 1,

          treesitter = { 'lsp' },

          -- Define columns and their configuration
          columns = {
            {
              'label',
              'label_description',
              gap = 1,
            },
            {
              'kind_icon',
              'kind',
              gap = 1,
            },
          },

          -- Definitions for possible components to render, in order of priority
          components = {
            kind_icon = {
              ellipsis = false,
              text = function(ctx) return ctx.kind_icon .. ctx.icon_gap end,
              highlight = function(ctx)
                return require('blink.cmp.completion.windows.render.tailwind').get_highlight(ctx)
                  or ('BlinkCmpKind' .. ctx.kind)
              end,
            },

            kind = {
              ellipsis = false,
              width = {
                fill = true,
              },
              text = function(ctx) return ctx.kind end,
              highlight = function(ctx)
                return require('blink.cmp.completion.windows.render.tailwind').get_highlight(ctx)
                  or ('BlinkCmpKind' .. ctx.kind)
              end,
            },

            label = {
              width = {
                fill = true,
                max = 60,
              },
              text = function(ctx) return ctx.label .. ctx.label_detail end,
              highlight = function(ctx)
                -- Label and label details
                local highlights = {}
                if ctx.deprecated then
                  table.insert(highlights, {
                    0,
                    #ctx.label,
                    group = 'BlinkCmpLabelDeprecated',
                  })
                end
                if ctx.matched_indices then
                  for _, matched_index in ipairs(ctx.matched_indices) do
                    table.insert(highlights, {
                      matched_index,
                      matched_index + 1,
                      group = 'BlinkCmpLabelMatch',
                    })
                  end
                end
                return highlights
              end,
            },

            label_description = {
              width = {
                max = 30,
              },
              text = function(ctx) return ctx.label_description end,
              highlight = 'BlinkCmpLabelDescription',
            },
          },
        },
      },

      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        treesitter_highlighting = true,
        window = {
          min_width = 10,
          max_width = 60,
          max_height = 20,
          border = 'none',
          winblend = 0,
          winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None',
          -- Note that the gutter will be disabled when border ~= 'none'
          scrollbar = false,
        },
      },

      -- Displays a preview of the selected item on the current line
      ghost_text = {
        enabled = true,
      },
    },

    -- Experimental signature help support which is disabled by default
    signature = {
      enabled = true,
      trigger = {
        blocked_trigger_characters = {},
        blocked_retrigger_characters = {},
        -- When true, will show the signature help window when the cursor comes after a trigger character when entering insert mode
        show_on_insert_on_trigger_character = true,
      },
      window = {
        min_width = 1,
        max_width = 100,
        max_height = 10,
        border = 'none',
        winblend = 0,
        winhighlight = 'Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder',
        scrollbar = false,
        -- Note that the gutter will be disabled when border ~= 'none'
        treesitter_highlighting = true,
      },
    },

    fuzzy = {
      -- Frencency tracks the most recently/frequently used items and boosts the score of the item
      use_frecency = true,
      -- Proximity bonus boosts the score of items with a value in the buffer
      use_proximity = true,
      sorts = { 'label', 'kind', 'score' },
    },
  },

  config = function()
    local notify = require('utils.notify')

    -- Terminal compatibility fix for Ctrl+Space
    vim.keymap.set('i', '<Nul>', '<C-Space>', {
      remap = false,
    })
    vim.keymap.set('i', '<C-@>', '<C-Space>', {
      remap = false,
    })

    -- Manual completion trigger for debugging
    vim.api.nvim_create_user_command('BlinkShow', function() require('blink.cmp').show() end, {
      desc = 'Manually trigger blink.cmp completion',
    })

    -- Override the Ctrl+Space mapping with proper blink.cmp show
    vim.keymap.set('i', '<C-Space>', function()
      local blink = require('blink.cmp')
      if blink.is_visible() then
        blink.hide()
        notify.info('Blink CMP', 'Completion menu hidden')
      else
        blink.show()
        notify.info('Blink CMP', 'Completion menu shown')
      end
    end, {
      desc = 'Toggle blink.cmp completion',
    })

    -- Also add alternatives that force show completion
    vim.keymap.set('i', '<C-n>', function() require('blink.cmp').show() end, {
      desc = 'Show completion (Ctrl+N)',
    })

    vim.keymap.set('i', '<C-y>', function() require('blink.cmp').show() end, {
      desc = 'Show completion (Ctrl+Y)',
    })

    -- Additional debug keymaps for testing
    vim.keymap.set('n', '<leader>ct', function()
      notify.info('Blink CMP', 'Testing completion triggers:')
      print('Available triggers:')
      print('  Ctrl+Space (toggle), Ctrl+N, Ctrl+Y, Ctrl+@')
      print('  Use :BlinkShow to manually trigger')
      print('  Current completion state: ' .. (require('blink.cmp').is_visible() and 'visible' or 'hidden'))
    end, {
      desc = 'Test completion triggers',
    })
  end,

  -- Allows extending the providers array elsewhere in your config
  -- without having to redefine it
  opts_extend = { 'sources.default' },
}
