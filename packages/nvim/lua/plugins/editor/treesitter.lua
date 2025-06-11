-- Treesitter configuration
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = 'BufReadPost',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-treesitter/nvim-treesitter-context',
    'windwp/nvim-ts-autotag',
  },
  opts = {
    -- Enhanced language support for modern web development
    ensure_installed = { -- Web Development Core
      'html',
      'css',
      'scss',
      'javascript',
      'typescript',
      'tsx',
      'jsdoc', -- Modern Web Frameworks
      'astro',
      'svelte',
      'vue', -- Styling & Templates
      'json',
      'json5',
      'jsonc',
      'yaml',
      'toml',
      'xml', -- Documentation & Markup
      'markdown',
      'markdown_inline', -- Programming Languages
      'lua',
      'luadoc',
      'luap',
      'java',
      'c',
      'cpp',
      'rust',
      'go',
      'python',
      'php',
      'ruby', -- Shell & Config
      'bash',
      'fish',
      'dockerfile',
      'vim',
      'vimdoc',
      'regex',
      'gitignore',
      'gitcommit',
      'git_config',
      'git_rebase',
      -- Build Tools & Package Managers
      'make',
      'cmake', -- Data & Query Languages
      'sql',
      'graphql', -- Specialized
      'diff',
      'comment',
    },
    auto_install = true,

    -- Enhanced highlighting
    highlight = {
      enable = true,
      use_languagetree = true,
      additional_vim_regex_highlighting = { 'markdown' },
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then return true end
      end,
    },

    -- Enhanced indentation
    indent = {
      enable = true,
      disable = { 'python', 'yaml' }, -- These have issues with treesitter indent
    },

    -- Enhanced text objects
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['ai'] = '@conditional.outer',
          ['ii'] = '@conditional.inner',
          ['al'] = '@loop.outer',
          ['il'] = '@loop.inner',
          ['ab'] = '@block.outer',
          ['ib'] = '@block.inner',
          ['as'] = '@statement.outer',
          ['is'] = '@statement.inner',
          ['ad'] = '@comment.outer',
          ['id'] = '@comment.inner',
          ['am'] = '@call.outer',
          ['im'] = '@call.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          [']f'] = '@function.outer',
          [']c'] = '@class.outer',
          [']a'] = '@parameter.inner',
          [']i'] = '@conditional.outer',
          [']l'] = '@loop.outer',
          [']s'] = '@statement.outer',
          [']m'] = '@call.outer',
        },
        goto_next_end = {
          [']F'] = '@function.outer',
          [']C'] = '@class.outer',
          [']A'] = '@parameter.inner',
          [']I'] = '@conditional.outer',
          [']L'] = '@loop.outer',
          [']S'] = '@statement.outer',
          [']M'] = '@call.outer',
        },
        goto_previous_start = {
          ['[f'] = '@function.outer',
          ['[c'] = '@class.outer',
          ['[a'] = '@parameter.inner',
          ['[i'] = '@conditional.outer',
          ['[l'] = '@loop.outer',
          ['[s'] = '@statement.outer',
          ['[m'] = '@call.outer',
        },
        goto_previous_end = {
          ['[F'] = '@function.outer',
          ['[C'] = '@class.outer',
          ['[A'] = '@parameter.inner',
          ['[I'] = '@conditional.outer',
          ['[L'] = '@loop.outer',
          ['[S'] = '@statement.outer',
          ['[M'] = '@call.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>xp'] = '@parameter.inner',
          ['<leader>xf'] = '@function.outer',
        },
        swap_previous = {
          ['<leader>xP'] = '@parameter.inner',
          ['<leader>xF'] = '@function.outer',
        },
      },
      lsp_interop = {
        enable = true,
        border = 'single',
        peek_definition_code = {
          ['<leader>gp'] = '@function.outer',
          ['<leader>gP'] = '@class.outer',
        },
      },
    },

    -- Enhanced incremental selection
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = 'gnn',
        node_incremental = 'grn',
        scope_incremental = 'grc',
        node_decremental = 'grm',
      },
    },

    -- Enhanced refactoring support
    refactor = {
      highlight_definitions = {
        enable = true,
      },
      highlight_current_scope = {
        enable = false,
      },
      smart_rename = {
        enable = true,
        keymaps = {
          smart_rename = '<leader>rn',
        },
      },
      navigation = {
        enable = true,
        keymaps = {
          goto_definition = '<leader>gnd',
          list_definitions = '<leader>gnD',
          list_definitions_toc = '<leader>gO',
          goto_next_usage = '<leader>g*',
          goto_previous_usage = '<leader>g#',
        },
      },
    },

    -- Enhanced matching
    matchup = {
      enable = true,
    },

    -- Playground for testing
    playground = {
      enable = true,
      disable = {},
      updatetime = 25,
      persist_queries = false,
      keybindings = {
        toggle_query_editor = 'o',
        toggle_hl_groups = 'i',
        toggle_injected_languages = 't',
        toggle_anonymous_nodes = 'a',
        toggle_language_display = 'I',
        focus_language = 'f',
        unfocus_language = 'F',
        update = 'R',
        goto_node = '<cr>',
        show_help = '?',
      },
    },
  },

  config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)

    -- Configure treesitter context
    require('treesitter-context').setup({
      enable = true,
      max_lines = 0,
      min_window_height = 0,
      line_numbers = true,
      multiline_threshold = 20,
      trim_scope = 'outer',
      mode = 'cursor',
      separator = nil,
      zindex = 20,
      on_attach = nil,
    })

    -- Configure autotag with new API
    require('nvim-ts-autotag').setup({
      opts = {
        -- Defaults
        enable_close = true, -- Auto close tags
        enable_rename = true, -- Auto rename pairs of tags
        enable_close_on_slash = true, -- Auto close on trailing </
      },
      -- Also override individual filetype configs, these take priority.
      -- Empty by default, useful if one of the "opts" global settings
      -- doesn't work well in a specific filetype
      per_filetype = {
        ['html'] = {
          enable_close = false,
        },
      },
    })
  end,
}
