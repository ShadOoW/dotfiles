return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function() return vim.fn.executable('make') == 1 end,
    },
    'nvim-telescope/telescope-ui-select.nvim',
    {
      'nvim-tree/nvim-web-devicons',
      enabled = vim.g.have_nerd_font,
    }, -- Additional telescope extensions for enhanced functionality
    'nvim-telescope/telescope-project.nvim',
    'nvim-telescope/telescope-frecency.nvim',
    'nvim-telescope/telescope-symbols.nvim',
    {
      'nvim-telescope/telescope-file-browser.nvim',
      dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
    },
  },
  config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    -- Custom action to copy selected entry
    local copy_selected = function(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      if entry then
        local text_to_copy = nil

        -- Handle different entry types with robust type checking
        if entry.text and type(entry.text) == 'string' then
          -- Noice message entries
          text_to_copy = entry.text
        elseif entry.path and type(entry.path) == 'string' then
          -- File entries - use filename
          text_to_copy = vim.fn.fnamemodify(entry.path, ':t')
        elseif entry.display then
          -- Handle display strings - could be string or function
          if type(entry.display) == 'string' then
            text_to_copy = entry.display
          elseif type(entry.display) == 'function' then
            -- Try to call the display function safely
            local ok, result = pcall(entry.display, entry)
            if ok and type(result) == 'string' then
              text_to_copy = result
            else
              text_to_copy = 'Display function result'
            end
          else
            text_to_copy = tostring(entry.display)
          end
        elseif entry.value and type(entry.value) ~= 'function' then
          -- Handle non-function values
          text_to_copy = tostring(entry.value)
        end

        -- Final fallback - try to extract any meaningful text
        if not text_to_copy or text_to_copy == '' then
          -- Look for any string field in the entry
          for key, value in pairs(entry) do
            if type(value) == 'string' and value ~= '' then
              text_to_copy = value
              break
            end
          end

          -- Ultimate fallback
          if not text_to_copy then text_to_copy = 'Selected entry' end
        end

        -- Ensure we have a valid string before copying
        if text_to_copy and type(text_to_copy) == 'string' and text_to_copy ~= '' then
          vim.fn.setreg('+', text_to_copy)
          vim.fn.setreg('"', text_to_copy)
          vim.notify('Copied: ' .. text_to_copy, vim.log.levels.INFO)
        else
          vim.notify('Nothing to copy from this entry', vim.log.levels.WARN)
        end
      end
      actions.close(prompt_bufnr)
    end

    -- Custom action to copy file path (only for file entries)
    local copy_file_path = function(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      if entry then
        local file_path = entry.path or entry.filename
        if file_path and type(file_path) == 'string' then
          -- Get absolute path
          local absolute_path = vim.fn.fnamemodify(file_path, ':p')
          vim.fn.setreg('+', absolute_path)
          vim.fn.setreg('"', absolute_path)
          vim.notify('Copied path: ' .. absolute_path, vim.log.levels.INFO)
        else
          vim.notify('No file path available for this entry', vim.log.levels.WARN)
        end
      end
      actions.close(prompt_bufnr)
    end

    -- Custom action to copy relative path (only for file entries)
    local copy_relative_path = function(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      if entry then
        local file_path = entry.path or entry.filename
        if file_path and type(file_path) == 'string' then
          -- Get relative path from current working directory
          local relative_path = vim.fn.fnamemodify(file_path, ':.')
          vim.fn.setreg('+', relative_path)
          vim.fn.setreg('"', relative_path)
          vim.notify('Copied relative path: ' .. relative_path, vim.log.levels.INFO)
        else
          vim.notify('No file path available for this entry', vim.log.levels.WARN)
        end
      end
      actions.close(prompt_bufnr)
    end

    -- Custom action to toggle between select all and deselect all
    local toggle_select_all = function(prompt_bufnr)
      local picker = action_state.get_current_picker(prompt_bufnr)
      local multi_selection = picker:get_multi_selection()

      if #multi_selection > 0 then
        -- If items are selected, deselect all
        actions.drop_all(prompt_bufnr)
        vim.notify('Deselected all items', vim.log.levels.INFO)
      else
        -- If no items are selected, select all
        actions.select_all(prompt_bufnr)
        vim.notify('Selected all items', vim.log.levels.INFO)
      end
    end

    telescope.setup({
      defaults = {
        -- Visual & UI Enhancements
        prompt_prefix = '> ',
        selection_caret = '> ',
        entry_prefix = '  ',
        multi_icon = '+ ',

        -- Layout and sizing
        layout_strategy = 'horizontal',
        layout_config = {
          horizontal = {
            prompt_position = 'top',
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },

        -- Appearance
        borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
        color_devicons = false, -- Disable icons to fix display issues
        use_less = true,
        set_env = {
          ['COLORTERM'] = 'truecolor',
        },

        -- Performance & behavior
        file_ignore_patterns = {
          '%.git/',
          'node_modules/',
          '%.npm/',
          '__pycache__/',
          '%.pyc',
          'target/',
          'build/',
          'dist/',
          '%.o',
          '%.a',
          '%.out',
          '%.class',
          '%.jar',
          '%.pdf',
          '%.mkv',
          '%.mp4',
          '%.zip',
        },

        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',
          '--glob=!.git/',
        },

        -- Enhanced mappings
        mappings = {
          i = {
            -- Navigation
            ['<C-n>'] = actions.cycle_history_next,
            ['<C-p>'] = actions.cycle_history_prev,
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,

            -- Selection actions
            ['<C-c>'] = actions.close,
            ['<Down>'] = actions.move_selection_next,
            ['<Up>'] = actions.move_selection_previous,
            ['<CR>'] = actions.select_default,
            ['<C-x>'] = actions.select_horizontal,
            ['<C-v>'] = actions.select_vertical,
            ['<C-t>'] = actions.select_tab,

            -- Multi-selection
            ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
            ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
            ['<C-e>'] = actions.send_to_qflist + actions.open_qflist,
            ['<C-E>'] = actions.send_selected_to_qflist + actions.open_qflist,
            ['<C-a>'] = toggle_select_all,

            -- Preview controls
            ['<S-PageUp>'] = actions.preview_scrolling_up,
            ['<S-PageDown>'] = actions.preview_scrolling_down,

            -- Custom copy actions
            ['<C-y>'] = copy_selected,
            ['<C-P>'] = copy_file_path,
            ['<C-r>'] = copy_relative_path,

            -- Quick close
            ['<esc>'] = actions.close,
          },
          n = {
            -- Navigation
            ['<esc>'] = actions.close,
            ['<CR>'] = actions.select_default,
            ['<C-x>'] = actions.select_horizontal,
            ['<C-v>'] = actions.select_vertical,
            ['<C-t>'] = actions.select_tab,

            -- Multi-selection
            ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
            ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
            ['<C-e>'] = actions.send_to_qflist + actions.open_qflist,
            ['<C-E>'] = actions.send_selected_to_qflist + actions.open_qflist,
            ['<C-a>'] = toggle_select_all,

            -- Movement
            ['j'] = actions.move_selection_next,
            ['k'] = actions.move_selection_previous,
            ['H'] = actions.move_to_top,
            ['M'] = actions.move_to_middle,
            ['L'] = actions.move_to_bottom,

            -- Preview controls
            ['<S-PageUp>'] = actions.preview_scrolling_up,
            ['<S-PageDown>'] = actions.preview_scrolling_down,

            -- Custom copy actions
            ['y'] = copy_selected,
            ['Y'] = copy_file_path,
            ['<C-y>'] = copy_selected,
            ['<C-r>'] = copy_relative_path,

            -- Quick actions
            ['gg'] = actions.move_to_top,
            ['G'] = actions.move_to_bottom,
            ['?'] = actions.which_key,
          },
        },

        -- Enhanced preview
        preview = {
          check_mime_type = true,
          filesize_limit = 25, -- MB
          timeout = 250,
          treesitter = true,
          mime_hook = function(filepath, bufnr, opts)
            local is_image = function(fp)
              local image_extensions = { 'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'ico', 'svg' }
              local split_path = vim.split(fp:lower(), '.', {
                plain = true,
              })
              local extension = split_path[#split_path]
              return vim.tbl_contains(image_extensions, extension)
            end

            if is_image(filepath) then
              local term = vim.api.nvim_open_term(bufnr, {})
              local function send_output(_, data, _)
                for _, d in ipairs(data) do
                  vim.api.nvim_chan_send(term, d .. '\r\n')
                end
              end
              vim.fn.jobstart({ 'catimg', filepath }, {
                on_stdout = send_output,
                stdout_buffered = true,
                pty = true,
              })
            else
              require('telescope.previewers.utils').set_preview_message(
                bufnr,
                opts.winid,
                'Binary file cannot be previewed'
              )
            end
          end,
        },

        -- History
        history = {
          path = '~/.local/share/nvim/databases/telescope_history.sqlite3',
          limit = 100,
        },
      },

      -- Picker-specific configurations
      pickers = {
        find_files = {
          hidden = true,
          follow = true,
          theme = 'dropdown',
          previewer = false,
          layout_config = {
            width = 0.8,
            height = 0.8,
          },
        },
        live_grep = {
          additional_args = function() return { '--hidden' } end,
          theme = 'ivy',
        },
        buffers = {
          theme = 'dropdown',
          previewer = false,
          initial_mode = 'normal',
          layout_config = {
            width = 0.8,
            height = 0.8,
          },
          sort_mru = true,
          ignore_current_buffer = true,
          mappings = {
            i = {
              ['<C-b>'] = actions.delete_buffer,
            },
            n = {
              ['<C-b>'] = actions.delete_buffer,
              ['d'] = actions.delete_buffer,
            },
          },
        },
        oldfiles = {
          theme = 'dropdown',
          previewer = false,
          layout_config = {
            width = 0.8,
            height = 0.8,
          },
        },
        help_tags = {
          theme = 'ivy',
        },
        keymaps = {
          theme = 'ivy',
        },
        diagnostics = {
          theme = 'ivy',
          initial_mode = 'normal',
        },
        git_files = {
          theme = 'dropdown',
          previewer = false,
          show_untracked = true,
        },
        git_commits = {
          theme = 'ivy',
        },
        git_branches = {
          theme = 'dropdown',
          previewer = false,
        },
        current_buffer_fuzzy_find = {
          theme = 'dropdown',
          layout_config = {
            width = 0.9,
            height = 0.9,
          },
        },
      },

      -- Extensions configuration
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown({
            layout_config = {
              width = 0.8,
              height = 0.8,
            },
          }),
        },

        frecency = {
          show_scores = false,
          show_unindexed = true,
          ignore_patterns = { '*.git/*', '*/tmp/*' },
          disable_devicons = true, -- Disable icons to fix display issues
        },

        file_browser = {
          theme = 'ivy',
          hijack_netrw = true, -- Hijack netrw to use telescope file browser
          mappings = {
            ['i'] = {
              -- your custom insert mode mappings
            },
            ['n'] = {
              -- your custom normal mode mappings
            },
          },
          -- Optional: Show hidden files by default
          hidden = true,
          -- Optional: Respect .gitignore
          respect_gitignore = false,
          -- Optional: Show parent directory
          grouped = true,
          -- Optional: Initial mode
          initial_mode = 'normal',
        },
      },
    })

    -- Enable extensions if they are installed
    pcall(telescope.load_extension, 'fzf')
    pcall(telescope.load_extension, 'ui-select')
    pcall(telescope.load_extension, 'frecency')
    pcall(telescope.load_extension, 'project')
    pcall(telescope.load_extension, 'aerial')
    pcall(telescope.load_extension, 'file_browser')

    -- Enhanced keymaps with better organization
    local builtin = require('telescope.builtin')
    local themes = require('telescope.themes')

    -- Core Search Functions
    vim.keymap.set(
      'n',
      '<leader>sf',
      function()
        builtin.find_files(themes.get_dropdown({
          previewer = false,
        }))
      end,
      {
        desc = 'Files',
      }
    )

    vim.keymap.set('n', '<leader>sg', function() builtin.live_grep(themes.get_ivy()) end, {
      desc = 'Grep',
    })

    vim.keymap.set('n', '<leader>sw', function() builtin.grep_string(themes.get_ivy()) end, {
      desc = 'Grep string under cursor',
    })

    vim.keymap.set(
      'n',
      '<leader>sb',
      function()
        builtin.buffers(themes.get_dropdown({
          previewer = false,
          initial_mode = 'normal',
          sort_mru = true,
        }))
      end,
      {
        desc = 'Buffers',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>s.',
      function()
        builtin.oldfiles(themes.get_dropdown({
          previewer = false,
        }))
      end,
      {
        desc = 'Recent files',
      }
    )

    -- Enhanced Telescope Functions
    vim.keymap.set('n', '<leader>s-', builtin.builtin, {
      desc = 'Telescope pickers',
    })
    vim.keymap.set('n', '<leader>sr', builtin.resume, {
      desc = 'Resume last search',
    })
    vim.keymap.set('n', '<leader>sH', builtin.help_tags, {
      desc = 'Help tags',
    })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, {
      desc = 'Keymaps',
    })
    vim.keymap.set(
      'n',
      '<leader>sd',
      function()
        builtin.diagnostics({
          bufnr = 0,
          severity_sort = true,
          severity_limit = vim.diagnostic.severity.WARN,
        })
      end,
      {
        desc = 'Diagnostics',
      }
    )

    -- Advanced Search Functions
    vim.keymap.set(
      'n',
      '<leader>s/',
      function()
        builtin.current_buffer_fuzzy_find(themes.get_dropdown({
          winblend = 10,
          previewer = false,
          layout_config = {
            width = 0.9,
            height = 0.9,
          },
        }))
      end,
      {
        desc = 'Current buffer',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>s?',
      function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Buffers',
        })
      end,
      {
        desc = 'Open buffers',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>sn',
      function()
        builtin.find_files({
          cwd = vim.fn.stdpath('config'),
          prompt_title = 'Neovim Config Files',
        })
      end,
      {
        desc = 'Neovim config files',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>sp',
      function()
        builtin.find_files({
          cwd = '~/mnt/backup/code',
          prompt_title = 'Project Files',
        })
      end,
      {
        desc = 'Project files',
      }
    )

    vim.keymap.set('n', '<leader>sP', function()
      -- Interactive projects directory selector
      local input = vim.fn.input('Projects directory (default: /mnt/backup/code): ', '/mnt/backup/code')
      if input ~= '' then
        local expanded_path = vim.fn.expand(input)
        if vim.fn.isdirectory(expanded_path) == 1 then
          builtin.find_files({
            cwd = expanded_path,
            prompt_title = 'Project Files (' .. vim.fn.fnamemodify(expanded_path, ':~') .. ')',
          })
        else
          vim.notify('Directory not found: ' .. expanded_path, vim.log.levels.ERROR)
        end
      end
    end, {
      desc = 'Project files (choose directory)',
    })

    -- Extension Keymaps
    vim.keymap.set(
      'n',
      '<leader>se',
      function()
        require('telescope').extensions.file_browser.file_browser({
          path = vim.fn.expand('%:p:h'),
          cwd = vim.fn.getcwd(),
          respect_gitignore = false,
          hidden = true,
          grouped = true,
          previewer = false,
          initial_mode = 'normal',
          layout_config = {
            height = 40,
          },
        })
      end,
      {
        desc = 'File browser',
      }
    )

    vim.keymap.set(
      'n',
      '<leader>sF',
      function()
        require('telescope').extensions.frecency.frecency(themes.get_dropdown({
          previewer = false,
        }))
      end,
      {
        desc = 'Frequent files',
      }
    )

    -- LSP Integration
    vim.keymap.set('n', '<leader>ss', function() builtin.lsp_document_symbols(themes.get_ivy()) end, {
      desc = 'Document symbols',
    })

    vim.keymap.set('n', '<leader>sS', function() vim.lsp.buf.workspace_symbol() end, {
      desc = 'Workspace symbols',
    })

    -- Enhanced Tags & Symbol Navigation (integrated from enhanced-telescope-tags.lua)
    local enhanced_symbols_config = function()
      return themes.get_dropdown({
        prompt_title = '🏷️  Document Symbols',
        previewer = true,
        layout_config = {
          width = 0.9,
          height = 0.8,
        },
        symbol_width = 50,
        symbol_type_width = 12,
        path_display = { 'smart' },
        show_line = true,
        fname_width = 30,
        symbol_highlights = {
          Function = 'Function',
          Method = 'Function',
          Class = 'Type',
          Variable = 'Identifier',
          Constant = 'Constant',
          Module = 'Include',
          Namespace = 'Include',
          Interface = 'Type',
          Struct = 'Type',
          Enum = 'Type',
          Field = 'Identifier',
          Property = 'Identifier',
        },
      })
    end

    -- Enhanced tag keybindings
    vim.keymap.set('n', '<leader>ts', function() builtin.lsp_document_symbols(enhanced_symbols_config()) end, {
      desc = 'Document Symbols (Enhanced)',
      silent = true,
    })

    vim.keymap.set(
      'n',
      '<leader>tS',
      function()
        builtin.lsp_dynamic_workspace_symbols(themes.get_ivy({
          prompt_title = '🌐 Workspace Symbols',
        }))
      end,
      {
        desc = 'Workspace Symbols',
        silent = true,
      }
    )

    vim.keymap.set(
      'n',
      '<leader>tb',
      function()
        builtin.treesitter(themes.get_dropdown({
          prompt_title = '🌳 Buffer Symbols (Treesitter)',
          layout_config = {
            width = 0.8,
            height = 0.7,
          },
        }))
      end,
      {
        desc = 'Buffer Symbols (Treesitter)',
        silent = true,
      }
    )

    -- Type-specific symbol filtering
    vim.keymap.set(
      'n',
      '<leader>tf',
      function()
        builtin.lsp_document_symbols(vim.tbl_extend('force', enhanced_symbols_config(), {
          symbols = { 'function', 'method' },
          prompt_title = '⚡ Functions & Methods',
        }))
      end,
      {
        desc = 'Functions & Methods',
        silent = true,
      }
    )

    vim.keymap.set(
      'n',
      '<leader>th',
      function()
        builtin.jumplist(themes.get_dropdown({
          prompt_title = '📋 Locations',
          layout_config = {
            width = 0.8,
            height = 0.6,
          },
        }))
      end,
      {
        desc = 'Locations History',
        silent = true,
      }
    )

    vim.keymap.set(
      'n',
      '<leader>tT',
      function()
        builtin.tags(themes.get_ivy({
          prompt_title = '🏷️  Project Tags (ctags)',
          only_sort_tags = true,
        }))
      end,
      {
        desc = 'Project Tags (ctags)',
        silent = true,
      }
    )

    vim.keymap.set(
      'n',
      '<leader>tt',
      function()
        builtin.current_buffer_tags(themes.get_dropdown({
          prompt_title = '📄 Buffer Tags',
          layout_config = {
            width = 0.7,
            height = 0.6,
          },
        }))
      end,
      {
        desc = 'Buffer Tags',
        silent = true,
      }
    )

    -- Telescope aerial integration
    vim.keymap.set('n', '<leader>ta', '<cmd>Telescope aerial<CR>', {
      desc = 'Telescope Aerial',
      silent = true,
    })

    -- Quick Actions
    vim.keymap.set(
      'n',
      '<C-p>',
      function()
        builtin.find_files(themes.get_dropdown({
          previewer = false,
        }))
      end,
      {
        desc = 'Quick file finder',
      }
    )

    vim.keymap.set('n', '<C-f>', function() builtin.live_grep(themes.get_ivy()) end, {
      desc = 'Quick live grep',
    })
  end,
}
