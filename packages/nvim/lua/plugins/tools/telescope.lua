-- Enhanced Telescope Configuration
-- Features:
-- - Enter opens all selected files (if multiple are selected with Tab)
-- - Alt-B sends selected files to buffer list (background loading)
--
-- Usage:
-- 1. Use Tab to select multiple files in telescope
-- 2. Press Enter to open all selected files
-- 3. Press Alt-B to add selected files to buffer list without opening them
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
    'nvim-telescope/telescope-file-browser.nvim', -- File browser extension
    'LukasPietzschmann/telescope-tabs', -- Tab management extension
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

    -- Custom action to open all selected files or current selection
    local open_all_selected = function(prompt_bufnr)
      local picker = action_state.get_current_picker(prompt_bufnr)
      local multi_selection = picker:get_multi_selection()

      -- If multiple files are selected, open all of them
      if #multi_selection > 0 then
        local opened_files = {}
        for _, entry in ipairs(multi_selection) do
          if entry.path or entry.filename then
            local file_path = entry.path or entry.filename
            table.insert(opened_files, file_path)
          end
        end

        if #opened_files > 0 then
          actions.close(prompt_bufnr)
          -- Open files after closing telescope to avoid conflicts
          vim.schedule(function()
            for _, file_path in ipairs(opened_files) do
              -- Use the path as-is from Telescope, don't modify it
              vim.cmd('edit ' .. vim.fn.fnameescape(file_path))
            end
            vim.notify('Opened ' .. #opened_files .. ' files', vim.log.levels.INFO)
          end)
        else
          -- Fallback if no valid files found in selection
          actions.select_default(prompt_bufnr)
        end
      else
        -- If no multi-selection, use default behavior
        actions.select_default(prompt_bufnr)
      end
    end

    -- Custom action to send all selected files to buffer list
    local send_to_buffer_list = function(prompt_bufnr)
      local picker = action_state.get_current_picker(prompt_bufnr)
      local multi_selection = picker:get_multi_selection()

      if #multi_selection > 0 then
        local added_files = {}
        for _, entry in ipairs(multi_selection) do
          if entry.path or entry.filename then
            local file_path = entry.path or entry.filename
            table.insert(added_files, file_path)
          end
        end
        actions.close(prompt_bufnr)

        -- Add files to buffer list after closing telescope
        vim.schedule(function()
          for _, file_path in ipairs(added_files) do
            -- Use the path as-is from Telescope, don't modify it
            vim.cmd('badd ' .. vim.fn.fnameescape(file_path))
          end
          vim.notify('Added ' .. #added_files .. ' files to buffer list', vim.log.levels.INFO)
        end)
      else
        -- If no multi-selection, add current entry to buffer list
        local entry = action_state.get_selected_entry()
        if entry and (entry.path or entry.filename) then
          local file_path = entry.path or entry.filename
          actions.close(prompt_bufnr)
          vim.schedule(function()
            -- Use the path as-is from Telescope, don't modify it
            vim.cmd('badd ' .. vim.fn.fnameescape(file_path))
            vim.notify('Added file to buffer list: ' .. vim.fn.fnamemodify(file_path, ':t'), vim.log.levels.INFO)
          end)
        else
          actions.close(prompt_bufnr)
        end
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
            ['<CR>'] = open_all_selected,
            ['<C-s>'] = actions.select_horizontal,
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

            -- Buffer list actions
            ['<A-b>'] = send_to_buffer_list,

            -- Quick close - ensure escape completely closes telescope
            ['<esc>'] = function(prompt_bufnr) actions.close(prompt_bufnr) end,
            ['<S-esc>'] = function(prompt_bufnr)
              -- Switch to normal mode instead of closing
              vim.cmd('stopinsert')
            end,
          },
          n = {
            -- Navigation
            ['<esc>'] = actions.close,
            ['<S-esc>'] = actions.close, -- In normal mode, both escape variants close
            ['<CR>'] = open_all_selected,
            ['<C-s>'] = actions.select_horizontal,
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

            -- Buffer list actions
            ['<A-b>'] = send_to_buffer_list,

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
          theme = 'ivy',
          layout_config = {
            height = 0.5,
          },
        },
        live_grep = {
          additional_args = function() return { '--hidden' } end,
          theme = 'ivy',
          layout_config = {
            height = 0.5,
          },
        },
        buffers = {
          theme = 'ivy',
          initial_mode = 'normal',
          layout_config = {
            height = 0.5,
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
          theme = 'ivy',
          layout_config = {
            height = 0.5,
          },
        },
        help_tags = {
          theme = 'ivy',
          layout_config = {
            height = 0.5,
          },
        },
        keymaps = {
          theme = 'ivy',
          layout_config = {
            height = 0.5,
          },
        },
        diagnostics = {
          theme = 'ivy',
          initial_mode = 'normal',
          layout_config = {
            height = 0.5,
          },
        },
        git_files = {
          theme = 'ivy',
          show_untracked = true,
          layout_config = {
            height = 0.5,
          },
        },
        git_commits = {
          theme = 'ivy',
          layout_config = {
            height = 0.5,
          },
        },
        git_branches = {
          theme = 'ivy',
          layout_config = {
            height = 0.5,
          },
        },
        current_buffer_fuzzy_find = {
          theme = 'ivy',
          layout_config = {
            height = 0.5,
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
          ignore_patterns = { '*.git/*', '*/tmp/*', '*/node_modules/*', '*/.venv/*' },
          disable_devicons = true, -- Disable icons to fix display issues
          -- Use matcher to filter files by current working directory
          matcher = 'fuzzy',
          -- Show only files from current working directory and subdirectories
          path_display = { 'smart' },
          -- Filter results to current working directory
          filter_delimiter = ':',
        },

        file_browser = {
          theme = 'ivy',
          hijack_netrw = true, -- Hijack netrw to use telescope file browser
          mappings = {
            ['i'] = {
              -- File operations in insert mode
              ['<C-c>'] = function(prompt_bufnr) require('telescope.actions').close(prompt_bufnr) end,
              ['<C-o>'] = function(prompt_bufnr)
                local fb_actions = require('telescope').extensions.file_browser.actions
                fb_actions.open(prompt_bufnr)
              end,
              ['<C-r>'] = function(prompt_bufnr)
                local fb_actions = require('telescope').extensions.file_browser.actions
                fb_actions.rename(prompt_bufnr)
              end,
              ['<C-d>'] = function(prompt_bufnr)
                local fb_actions = require('telescope').extensions.file_browser.actions
                fb_actions.remove(prompt_bufnr)
              end,
              ['<C-n>'] = function(prompt_bufnr)
                local fb_actions = require('telescope').extensions.file_browser.actions
                fb_actions.create(prompt_bufnr)
              end,
            },
            ['n'] = {
              -- File operations in normal mode
              ['o'] = function(prompt_bufnr)
                local fb_actions = require('telescope').extensions.file_browser.actions
                fb_actions.open(prompt_bufnr)
              end,
              ['r'] = function(prompt_bufnr)
                local fb_actions = require('telescope').extensions.file_browser.actions
                fb_actions.rename(prompt_bufnr)
              end,
              ['d'] = function(prompt_bufnr)
                local fb_actions = require('telescope').extensions.file_browser.actions
                fb_actions.remove(prompt_bufnr)
              end,
              ['c'] = function(prompt_bufnr)
                local fb_actions = require('telescope').extensions.file_browser.actions
                fb_actions.create(prompt_bufnr)
              end,
              ['m'] = function(prompt_bufnr)
                local fb_actions = require('telescope').extensions.file_browser.actions
                fb_actions.move(prompt_bufnr)
              end,
              ['y'] = function(prompt_bufnr)
                local fb_actions = require('telescope').extensions.file_browser.actions
                fb_actions.copy(prompt_bufnr)
              end,
              ['h'] = function(prompt_bufnr)
                local fb_actions = require('telescope').extensions.file_browser.actions
                fb_actions.goto_parent_dir(prompt_bufnr)
              end,
              ['l'] = function(prompt_bufnr)
                local fb_actions = require('telescope').extensions.file_browser.actions
                fb_actions.change_cwd(prompt_bufnr)
              end,
              ['g'] = function(prompt_bufnr)
                local fb_actions = require('telescope').extensions.file_browser.actions
                fb_actions.goto_home_dir(prompt_bufnr)
              end,
              ['w'] = function(prompt_bufnr)
                local fb_actions = require('telescope').extensions.file_browser.actions
                fb_actions.goto_cwd(prompt_bufnr)
              end,
              ['t'] = function(prompt_bufnr)
                local fb_actions = require('telescope').extensions.file_browser.actions
                fb_actions.toggle_hidden(prompt_bufnr)
              end,
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
          -- Fix path display
          path_display = { 'smart' },
          -- Enable depth level display
          depth = 1,
          -- Auto depth adjustment
          auto_depth = true,
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
    pcall(telescope.load_extension, 'telescope-tabs')
  end,
}
