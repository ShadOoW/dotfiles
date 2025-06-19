-- Modern Obsidian.nvim based note-taking workflow
-- Focused on obsidian ecosystem plugins with Tokyo Night theme
return { -- Core obsidian.nvim plugin for seamless Obsidian vault integration
  {
    'epwalsh/obsidian.nvim',
    version = '*',
    lazy = false,
    -- ft = 'markdown',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
      'nvim-telescope/telescope.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {
      workspaces = { {
        name = 'notes',
        path = '/mnt/share/notes',
      } },

      -- Daily notes configuration
      daily_notes = {
        folder = 'daily',
        date_format = '%Y-%m-%d',
        alias_format = '%B %-d, %Y',
        template = nil,
      },

      -- Note completion and linking
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },

      -- Template configuration
      templates = {
        subdir = 'templates',
        date_format = '%Y-%m-%d',
        time_format = '%H:%M',
        substitutions = {},
      },

      -- Note creation and naming
      new_notes_location = 'notes_subdir',
      notes_subdir = 'inbox',

      -- Note ID generation with timestamp and slug
      note_id_func = function(title)
        local suffix = ''
        if title ~= nil then
          suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
        else
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. '-' .. suffix
      end,

      -- Note frontmatter function
      note_frontmatter_func = function(note)
        local out = {
          id = note.id,
          aliases = note.aliases,
          tags = note.tags,
        }
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        return out
      end,

      -- Image handling configuration
      attachments = {
        img_folder = 'assets/images',
        img_text_func = function(client, path)
          local link_path
          local vault_relative_path = client:vault_relative_path(path)
          if vault_relative_path ~= nil then
            link_path = vault_relative_path
          else
            link_path = tostring(path)
          end
          local display_name = vim.fs.basename(link_path)
          return string.format('![%s](%s)', display_name, link_path)
        end,
      },

      -- UI configuration with Tokyo Night colors
      -- UI disabled to prevent conflicts with render-markdown.nvim
      ui = {
        enable = false, -- Disable obsidian.nvim UI to use render-markdown.nvim instead
      },

      -- Telescope integration
      finder = 'telescope.nvim',
      finder_mappings = {
        new = '<C-x>',
        insert_link = '<C-l>',
      },

      -- URL handling
      follow_url_func = function(url) vim.fn.jobstart({ 'xdg-open', url }) end,

      -- Configuration options
      use_advanced_uri = false,
      open_app_foreground = false,
      sort_by = 'modified',
      sort_reversed = true,
      search_max_lines = 1000,
      open_notes_in = 'current',
    },

    config = function(_, opts)
      require('obsidian').setup(opts)

      -- Set conceallevel for markdown files to enable obsidian UI features
      -- Template insertion buffer fix (conceallevel handled globally in options.lua)
      local obsidian_group = vim.api.nvim_create_augroup('ObsidianTemplates', {
        clear = true,
      })

      vim.api.nvim_create_autocmd('User', {
        group = obsidian_group,
        pattern = 'ObsidianTemplate*',
        callback = function() vim.opt_local.modifiable = true end,
      })

      -- Comprehensive key mappings for obsidian functionality
      local keymap = vim.keymap.set
      local opts_desc = {
        silent = true,
        noremap = true,
      }

      -- Daily notes
      keymap(
        'n',
        '<leader>ad',
        '<cmd>ObsidianToday<cr>',
        vim.tbl_extend('force', opts_desc, {
          desc = 'Open today note',
        })
      )
      keymap(
        'n',
        '<leader>ay',
        '<cmd>ObsidianYesterday<cr>',
        vim.tbl_extend('force', opts_desc, {
          desc = 'Open yesterday note',
        })
      )
      keymap(
        'n',
        '<leader>aT',
        '<cmd>ObsidianTomorrow<cr>',
        vim.tbl_extend('force', opts_desc, {
          desc = 'Open tomorrow note',
        })
      )

      -- Note management
      keymap(
        'n',
        '<leader>an',
        '<cmd>ObsidianNew<cr>',
        vim.tbl_extend('force', opts_desc, {
          desc = 'Create new note',
        })
      )
      keymap(
        'n',
        '<leader>ao',
        '<cmd>ObsidianOpen<cr>',
        vim.tbl_extend('force', opts_desc, {
          desc = 'Open note in obsidian',
        })
      )
      keymap(
        'n',
        '<leader>ab',
        '<cmd>ObsidianBacklinks<cr>',
        vim.tbl_extend('force', opts_desc, {
          desc = 'Show backlinks',
        })
      )
      keymap(
        'n',
        '<leader>al',
        '<cmd>ObsidianLinks<cr>',
        vim.tbl_extend('force', opts_desc, {
          desc = 'Show links',
        })
      )

      -- Search and navigation
      keymap(
        'n',
        '<leader>af',
        '<cmd>ObsidianSearch<cr>',
        vim.tbl_extend('force', opts_desc, {
          desc = 'Search notes',
        })
      )
      keymap(
        'n',
        '<leader>aq',
        '<cmd>ObsidianQuickSwitch<cr>',
        vim.tbl_extend('force', opts_desc, {
          desc = 'Quick switch notes',
        })
      )
      keymap(
        'n',
        '<leader>ag',
        '<cmd>ObsidianFollowLink<cr>',
        vim.tbl_extend('force', opts_desc, {
          desc = 'Follow link under cursor',
        })
      )

      -- Templates and utilities
      keymap(
        'n',
        '<leader>ai',
        function()
          -- Ensure buffer is modifiable before template insertion
          vim.opt_local.modifiable = true
          vim.cmd('ObsidianTemplate')
        end,
        vim.tbl_extend('force', opts_desc, {
          desc = 'Insert template',
        })
      )
      keymap(
        'n',
        '<leader>ar',
        '<cmd>ObsidianRename<cr>',
        vim.tbl_extend('force', opts_desc, {
          desc = 'Rename note',
        })
      )
      keymap(
        'v',
        '<leader>aL',
        ':ObsidianLinkNew<cr>',
        vim.tbl_extend('force', opts_desc, {
          desc = 'Create link from selection',
        })
      )

      -- Workspace and tags
      keymap(
        'n',
        '<leader>aw',
        '<cmd>ObsidianWorkspace<cr>',
        vim.tbl_extend('force', opts_desc, {
          desc = 'Switch workspace',
        })
      )
      keymap(
        'n',
        '<leader>at',
        '<cmd>ObsidianTags<cr>',
        vim.tbl_extend('force', opts_desc, {
          desc = 'Browse tags',
        })
      )
    end,
  }, -- Enhanced markdown rendering with Tokyo Night theme
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
    ft = { 'markdown', 'obsidian' },
    opts = {
      file_types = { 'markdown', 'obsidian' },
      render_modes = { 'n', 'c', 't' },
      anti_conceal = {
        enabled = true,
        above = 1,
        below = 1,
      },
      heading = {
        enabled = true,
        sign = true,
        icons = { '󰲡 ', '󰲣 ', '�� ', '󰲧 ', '󰲩 ', '󰲫 ' },
        width = 'full',
        left_margin = 0,
        left_pad = 0,
        right_pad = 0,
        min_width = 0,
        backgrounds = {
          'RenderMarkdownH1Bg',
          'RenderMarkdownH2Bg',
          'RenderMarkdownH3Bg',
          'RenderMarkdownH4Bg',
          'RenderMarkdownH5Bg',
          'RenderMarkdownH6Bg',
        },
        foregrounds = {
          'RenderMarkdownH1',
          'RenderMarkdownH2',
          'RenderMarkdownH3',
          'RenderMarkdownH4',
          'RenderMarkdownH5',
          'RenderMarkdownH6',
        },
      },
      code = {
        enabled = true,
        style = 'full',
        border = 'thin',
        left_margin = 0,
        left_pad = 1,
        right_pad = 1,
        highlight = 'RenderMarkdownCode',
        highlight_inline = 'RenderMarkdownCodeInline',
      },
      bullet = {
        enabled = true,
        icons = { '●', '○', '◆', '◇' },
        left_pad = 0,
        right_pad = 1,
        highlight = 'RenderMarkdownBullet',
      },
      checkbox = {
        enabled = true,
        position = 'inline',
        unchecked = {
          icon = '',
          highlight = 'RenderMarkdownUnchecked',
          scope_highlight = nil,
        },
        checked = {
          icon = '󰱒',
          highlight = 'RenderMarkdownChecked',
          scope_highlight = nil,
        },
        custom = {
          todo = {
            raw = '[>]',
            rendered = ' ',
            highlight = 'RenderMarkdownTodo',
            scope_highlight = nil,
          },
          cancelled = {
            raw = '[~]',
            rendered = ' ',
            highlight = 'RenderMarkdownCancelled',
            scope_highlight = nil,
          },
          urgent = {
            raw = '[!]',
            rendered = ' ',
            highlight = 'RenderMarkdownUrgent',
            scope_highlight = nil,
          },
        },
      },
      callout = {
        note = {
          raw = '[!NOTE]',
          rendered = '󰋽 Note',
          highlight = 'RenderMarkdownInfo',
        },
        tip = {
          raw = '[!TIP]',
          rendered = '󰌶 Tip',
          highlight = 'RenderMarkdownSuccess',
        },
        important = {
          raw = '[!IMPORTANT]',
          rendered = '󰅾 Important',
          highlight = 'RenderMarkdownHint',
        },
        warning = {
          raw = '[!WARNING]',
          rendered = '󰀪 Warning',
          highlight = 'RenderMarkdownWarn',
        },
        caution = {
          raw = '[!CAUTION]',
          rendered = '󰳦 Caution',
          highlight = 'RenderMarkdownError',
        },
      },
      link = {
        enabled = true,
        image = '󰥶 ',
        hyperlink = '󰌹 ',
        highlight = 'RenderMarkdownLink',
        custom = {
          obsidian = {
            pattern = '%[%[.*%]%]',
            icon = '󰆼 ',
            highlight = 'RenderMarkdownLink',
          },
        },
      },
      sign = {
        enabled = true,
        highlight = 'RenderMarkdownSign',
      },
    },
    config = function(_, opts)
      require('render-markdown').setup(opts)

      -- Tokyo Night themed highlight groups
      local colors = {
        h1 = '#ff7a93',
        h2 = '#b4f9f8',
        h3 = '#ffc777',
        h4 = '#c3e88d',
        h5 = '#82aaff',
        h6 = '#c792ea',
        code = '#565f89',
        bullet = '#7dcfff',
        checkbox = '#9ece6a',
      }

      -- Apply Tokyo Night colors to markdown elements
      vim.api.nvim_set_hl(0, 'RenderMarkdownH1', {
        fg = colors.h1,
        bold = true,
      })
      vim.api.nvim_set_hl(0, 'RenderMarkdownH2', {
        fg = colors.h2,
        bold = true,
      })
      vim.api.nvim_set_hl(0, 'RenderMarkdownH3', {
        fg = colors.h3,
        bold = true,
      })
      vim.api.nvim_set_hl(0, 'RenderMarkdownH4', {
        fg = colors.h4,
        bold = true,
      })
      vim.api.nvim_set_hl(0, 'RenderMarkdownH5', {
        fg = colors.h5,
        bold = true,
      })
      vim.api.nvim_set_hl(0, 'RenderMarkdownH6', {
        fg = colors.h6,
        bold = true,
      })

      vim.api.nvim_set_hl(0, 'RenderMarkdownCode', {
        bg = colors.code,
      })
      vim.api.nvim_set_hl(0, 'RenderMarkdownCodeInline', {
        bg = colors.code,
        fg = '#ff9e64',
      })
      vim.api.nvim_set_hl(0, 'RenderMarkdownBullet', {
        fg = colors.bullet,
      })
      vim.api.nvim_set_hl(0, 'RenderMarkdownChecked', {
        fg = colors.checkbox,
      })
      vim.api.nvim_set_hl(0, 'RenderMarkdownUnchecked', {
        fg = '#565f89',
      })
      vim.api.nvim_set_hl(0, 'RenderMarkdownLink', {
        fg = '#73daca',
        underline = true,
      })

      -- Callout highlights
      vim.api.nvim_set_hl(0, 'RenderMarkdownInfo', {
        fg = '#7dcfff',
      })
      vim.api.nvim_set_hl(0, 'RenderMarkdownSuccess', {
        fg = '#9ece6a',
      })
      vim.api.nvim_set_hl(0, 'RenderMarkdownWarn', {
        fg = '#e0af68',
      })
      vim.api.nvim_set_hl(0, 'RenderMarkdownError', {
        fg = '#f7768e',
      })
    end,
  }, -- Enhanced markdown table editing
  {
    'dhruvasagar/vim-table-mode',
    ft = { 'markdown', 'obsidian' },
    config = function()
      vim.g.table_mode_corner = '|'
      vim.g.table_mode_delimiter = ' | '
      vim.g.table_mode_fillchar = '-'

      vim.keymap.set('n', '<leader>am', '<cmd>TableModeToggle<cr>', {
        desc = 'Toggle table mode',
      })
      vim.keymap.set('n', '<leader>ar', '<cmd>TableModeRealign<cr>', {
        desc = 'Realign table',
      })
    end,
  }, -- Clipboard image support
  {
    'HakonHarnes/img-clip.nvim',
    event = 'VeryLazy',
    ft = { 'markdown', 'obsidian' },
    opts = {
      filetypes = {
        markdown = {
          url_encode_path = true,
          template = '![$CURSOR]($FILE_PATH)',
          dir_path = 'assets/images',
        },
        obsidian = {
          url_encode_path = true,
          template = '![$CURSOR]($FILE_PATH)',
          dir_path = 'assets/images',
        },
      },
    },
    keys = { {
      '<leader>ac',
      '<cmd>PasteImage<cr>',
      desc = 'Paste clipboard image',
    } },
  }, -- Enhanced folding for markdown
  {
    'masukomi/vim-markdown-folding',
    ft = { 'markdown', 'obsidian' },
    config = function()
      vim.g.markdown_fold_style = 'nested'
      vim.g.markdown_fold_override_foldtext = 0
    end,
  }, -- Enhanced telescope integration for obsidian notes
  {
    'nvim-telescope/telescope.nvim',
    optional = true,
    config = function()
      local builtin = require('telescope.builtin')

      -- Obsidian-specific telescope pickers
      vim.keymap.set(
        'n',
        '<leader>asf',
        function()
          builtin.find_files({
            cwd = '/mnt/share/notes',
            prompt_title = 'Obsidian Notes',
            find_command = { 'rg', '--files', '--type', 'md' },
          })
        end,
        {
          desc = 'Find obsidian notes',
        }
      )

      vim.keymap.set(
        'n',
        '<leader>asg',
        function()
          builtin.live_grep({
            cwd = '/mnt/share/notes',
            prompt_title = 'Search in Notes',
            additional_args = { '--type=md' },
          })
        end,
        {
          desc = 'Grep in obsidian notes',
        }
      )
    end,
  },
}
