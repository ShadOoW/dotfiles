-- Mini editing modules
return {
  'echasnovski/mini.nvim',
  version = false,
  config = function()
    -- Core Editing Features
    -- Autopairs for brackets, quotes, etc.
    require('mini.pairs').setup({})

    -- Split or join arguments, lists, tables, etc.
    require('mini.splitjoin').setup({})

    -- Navigate by brackets and other items
    require('mini.bracketed').setup({})

    -- Add/delete/replace surroundings (enhanced version)
    require('mini.surround').setup({
      -- Add custom surroundings here if needed
      mappings = {
        add = 'sa', -- Add surrounding in Normal and Visual modes
        delete = 'sd', -- Delete surrounding
        find = 'sf', -- Find surrounding (to the right)
        find_left = 'sF', -- Find surrounding (to the left)
        highlight = 'sh', -- Highlight surrounding
        replace = 'sc', -- Replace surrounding
        update_n_lines = 'sn', -- Update `n_lines`
      },
    })

    -- Enhanced comment functionality
    require('mini.comment').setup({
      -- Options which control module behavior
      options = {
        -- Function to compute custom 'commentstring' (optional)
        custom_commentstring = nil,

        -- Whether to ignore blank lines when adding comment
        ignore_blank_line = false,

        -- Whether to recognize as comment only lines without indent
        start_of_line = false,

        -- Whether to ensure single space pad for comment parts
        pad_comment_parts = true,
      },

      -- Module mappings. Use `''` (empty string) to disable one.
      mappings = {
        -- Toggle comment (like `gcip` - toggle comment paragraph)
        comment = 'gc',

        -- Toggle comment on current line
        comment_line = 'gcc',

        -- Toggle comment on visual selection
        comment_visual = 'gc',

        -- Define 'comment' textobject (like `dgc` - delete whole comment block)
        textobject = 'gc',
      },

      -- Hook functions to be executed at certain stage of commenting
      hooks = {
        -- Before successful commenting. Does nothing by default.
        pre = function() end,
        -- After successful commenting. Does nothing by default.
        post = function() end,
      },
    })

    -- Enhanced text objects and motions
    require('mini.ai').setup({
      -- Search method can be 'cover', 'cover_or_next', 'cover_or_prev', 'next', 'prev'
      search_method = 'cover_or_next',
      -- Custom text objects can be added here
      custom_textobjects = {
        -- Add your custom text objects here if needed
      },
    })

    -- Trailing whitespace management with automatic trimming
    require('mini.trailspace').setup({
      -- Highlight only in specific filetypes (nil means all)
      only_in_normal_buffers = true,
    })

    -- File explorer
    local files_win_config = nil
    require('mini.files').setup({
      -- Customize windows
      windows = {
        preview = true,
        width_focus = 30,
        width_preview = 40,
      },
      -- Customize content
      content = {
        -- Predicate for which files to show
        filter = nil,
        -- Prefix to show before item
        prefix = nil,
        -- Show only last component of path
        show_prefix = false,
      },
      mappings = {
        go_in_plus = '<CR>',
        go_out = '<BS>',
        show_help = 'g?',
        synchronize = '=', -- THIS IS KEY! Use this to save changes to disk
        trim_left = '<',
        trim_right = '>',
        close = 'q',
      },
      options = {
        -- Don't use netrw (prevents neo-tree from opening)
        use_as_default_explorer = false,
      },
    })

    -- Simple keymaps for mini.files
    vim.keymap.set('n', '|', function() require('mini.files').open() end, {
      desc = 'Open MiniFiles with current buffer',
    })

    -- Movement & Navigation
    -- Jump to any visible location with two-character input
    require('mini.jump2d').setup({
      mappings = {
        start_jumping = '<M-f>',
      },
      -- View configuration
      view = {
        -- Dim the source of jump spots
        dim = true,
        -- Number of steps ahead to be shown
        n_steps_ahead = 1,
      },
      -- Whether to disable showing non-first jump spot
      silent = false,
    })

    -- Track and visit recent files and buffers
    require('mini.visits').setup({})

    -- Utilities & Extras
    -- Remove buffers without losing window layout
    require('mini.bufremove').setup({})
  end,
}
