-- Modern Obsidian integration with enhanced features
-- Provides seamless note-taking and knowledge management
return {
  'epwalsh/obsidian.nvim',
  version = '*',
  lazy = true,
  ft = 'markdown',
  dependencies = { 'nvim-lua/plenary.nvim', 'hrsh7th/nvim-cmp', 'nvim-treesitter' },
  config = function()
    -- Basic validation to prevent errors
    local obsidian_vault = '/mnt/share/brain'
    if vim.fn.isdirectory(obsidian_vault) == 0 then
      vim.notify('Obsidian vault not found: ' .. obsidian_vault, vim.log.levels.WARN)
      return
    end

    -- Load obsidian module
    local obsidian = require('obsidian')

    -- Configure obsidian.nvim
    obsidian.setup({
      dir = obsidian_vault,
      notes_subdir = 'inbox',
      daily_notes = {
        folder = 'daily',
        date_format = '%Y-%m-%d',
      },
      templates = {
        subdir = 'templates',
        date_format = '%Y-%m-%d',
        time_format = '%H:%M',
      },
      note_id_func = function(title)
        -- Convert title to valid filename
        local slug = ''
        if title ~= nil then
          -- Convert to lowercase and replace spaces/invalid chars
          slug = title:lower():gsub(' ', '-'):gsub('[^%w%-]', '')
        end
        -- Add date prefix for unique ID
        return os.date('%Y%m%d') .. '-' .. (slug ~= '' and slug or 'untitled')
      end,
      disable_frontmatter = false,
      note_frontmatter_func = function(note)
        -- Customize frontmatter
        local out = {
          id = note.id,
          aliases = note.aliases,
          tags = note.tags,
          created = os.date('%Y-%m-%d'),
        }
        -- Add title if not empty
        if note.title and note.title ~= '' then out.title = note.title end
        return out
      end,
      ui = {
        enable = true,
        update_debounce = 200,
        checkboxes = {
          [' '] = {
            char = '☐',
            hl_group = 'ObsidianTodo',
          },
          ['x'] = {
            char = '✓',
            hl_group = 'ObsidianDone',
          },
          ['>'] = {
            char = '▶',
            hl_group = 'ObsidianRightArrow',
          },
          ['~'] = {
            char = '↻',
            hl_group = 'ObsidianTilde',
          },
        },
        external_link_icon = {
          char = '',
          hl_group = 'ObsidianExternal',
        },
        reference_text = {
          hl_group = 'ObsidianRefText',
        },
        highlight_text = {
          hl_group = 'ObsidianHighlightText',
        },
        tags = {
          hl_group = 'ObsidianTag',
        },
        hl_groups = {
          ObsidianTodo = {
            bold = true,
            fg = '#f78c6c',
          },
          ObsidianDone = {
            bold = true,
            fg = '#89ddff',
          },
          ObsidianRightArrow = {
            bold = true,
            fg = '#82aaff',
          },
          ObsidianTilde = {
            bold = true,
            fg = '#c792ea',
          },
          ObsidianRefText = {
            underline = true,
            fg = '#c792ea',
          },
          ObsidianExternal = {
            fg = '#82aaff',
          },
          ObsidianHighlightText = {
            bg = '#75662e',
          },
          ObsidianTag = {
            italic = true,
            fg = '#89ddff',
          },
        },
      },
      attachments = {
        img_folder = 'assets/imgs',
      },
      follow_url_func = function(url)
        -- Open URLs with default system handler
        vim.fn.jobstart({ 'xdg-open', url }, {
          detach = true,
        })
      end,
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
    })

    -- Load custom utils
    local utils = require('utils.obsidian')

    -- Create keymaps
    local keymap = require('utils.keymap')

    -- Note creation and navigation
    keymap.n('<leader>on', '<cmd>ObsidianNew<cr>', 'New note')
    keymap.n('<leader>oo', '<cmd>ObsidianOpen<cr>', 'Open in Obsidian')
    keymap.n('<leader>os', '<cmd>ObsidianSearch<cr>', 'Search notes')
    keymap.n('<leader>oq', '<cmd>ObsidianQuickSwitch<cr>', 'Quick switch')
    keymap.n('<leader>of', '<cmd>ObsidianFollowLink<cr>', 'Follow link')
    keymap.n('<leader>ob', '<cmd>ObsidianBacklinks<cr>', 'Show backlinks')
    keymap.n('<leader>ot', '<cmd>ObsidianTemplate<cr>', 'Insert template')

    -- Daily notes
    keymap.n('<leader>od', '<cmd>ObsidianToday<cr>', 'Open today')
    keymap.n('<leader>oy', '<cmd>ObsidianYesterday<cr>', 'Open yesterday')
    keymap.n('<leader>om', '<cmd>ObsidianTomorrow<cr>', 'Open tomorrow')

    -- Book notes
    keymap.n('<leader>oB', function()
      utils.ui.create_book_form(function(data)
        if data then utils.create.book_note(data) end
      end)
    end, 'Create book note')

    -- Link operations
    keymap.v('<leader>ol', ':ObsidianLink<cr>', 'Create link')
    keymap.v('<leader>oL', ':ObsidianLinkNew<cr>', 'Create link to new note')

    -- Tags
    keymap.n('<leader>oT', '<cmd>ObsidianTags<cr>', 'List tags')
  end,
}
