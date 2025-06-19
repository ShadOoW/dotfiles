-- Treesitter configuration
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = 'BufReadPost',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-treesitter/nvim-treesitter-context',
    'nvim-treesitter/nvim-treesitter-refactor',
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
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
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
      lsp_interop = {
        enable = true,
        border = 'single',
        peek_definition_code = {
          ['<leader>gp'] = '@function.outer',
          ['<leader>gP'] = '@class.outer',
        },
      },
    },

    -- Enhanced incremental selection with intuitive keymaps
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<CR>', -- Enter to start selection
        node_incremental = '<CR>', -- Enter to expand selection
        scope_incremental = '<S-CR>', -- Shift+Enter for scope
        node_decremental = '<BS>', -- Backspace to shrink selection
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
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
      },
    })

    -- Smart swap functionality - tries parameters first, then functions, then elements
    local ts_swap = require('nvim-treesitter.textobjects.swap')

    local function smart_swap(dir)
      local ts_utils = require('nvim-treesitter.ts_utils')
      local cursor_node = ts_utils.get_node_at_cursor()

      if not cursor_node then
        vim.notify('No treesitter node found at cursor', vim.log.levels.WARN, {
          title = 'Smart Swap',
          timeout = 2000,
        })
        return false
      end

      local node = cursor_node
      local node_types = {}
      while node do
        table.insert(node_types, node:type())
        node = node:parent()
      end

      -- Context-aware swapping based on actual node hierarchy
      local swap_targets = {}
      local hierarchy_str = table.concat(node_types, ' -> ')

      -- Check for array context
      if string.find(hierarchy_str, 'array_initializer') then
        -- Use manual array swapping instead of text objects
        local array_initializer = nil
        local array_element = cursor_node

        local node = cursor_node
        while node do
          if node:type() == 'array_initializer' then
            array_initializer = node
            break
          end
          -- Keep track of potential array element
          if
            node:type() == 'string_literal'
            or node:type() == 'decimal_integer_literal'
            or node:type() == 'identifier'
            or node:type() == 'expression'
          then
            array_element = node
          end
          node = node:parent()
        end

        if array_initializer then
          local elements = {}
          local current_index = nil

          for i = 0, array_initializer:child_count() - 1 do
            local child = array_initializer:child(i)
            if child and child:type() ~= '{' and child:type() ~= '}' and child:type() ~= ',' then
              table.insert(elements, child)
              if child == array_element then current_index = #elements end
            end
          end

          if current_index then
            local target_index = dir == 'next' and current_index + 1 or current_index - 1
            if target_index >= 1 and target_index <= #elements then
              local current_element = elements[current_index]
              local target_element = elements[target_index]

              local current_text = vim.treesitter.get_node_text(current_element, 0)
              local target_text = vim.treesitter.get_node_text(target_element, 0)

              local curr_start_row, curr_start_col, curr_end_row, curr_end_col = current_element:range()
              local target_start_row, target_start_col, target_end_row, target_end_col = target_element:range()

              -- Store cursor position relative to current element
              local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
              local cursor_offset_row = cursor_row - 1 - curr_start_row -- Convert to 0-indexed
              local cursor_offset_col = cursor_col - curr_start_col

              -- Determine which replacement to do first based on position
              -- Always replace the later one first to avoid coordinate shifts
              local frst_element, second_element, first_text, second_text
              local first_start_row, first_start_col, first_end_row, first_end_col
              local second_start_row, second_start_col, second_end_row, second_end_col
              local cursor_follows_first = false

              if
                curr_start_row > target_start_row
                or (curr_start_row == target_start_row and curr_start_col > target_start_col)
              then
                -- Current is after target, so replace current first
                first_element, second_element = current_element, target_element
                first_text, second_text = target_text, current_text
                first_start_row, first_start_col, first_end_row, first_end_col =
                  curr_start_row, curr_start_col, curr_end_row, curr_end_col
                second_start_row, second_start_col, second_end_row, second_end_col =
                  target_start_row, target_start_col, target_end_row, target_end_col
                cursor_follows_first = false -- cursor follows to target (second)
              else
                -- Target is after current, so replace target first
                first_element, second_element = target_element, current_element
                first_text, second_text = current_text, target_text
                first_start_row, first_start_col, first_end_row, first_end_col =
                  target_start_row, target_start_col, target_end_row, target_end_col
                second_start_row, second_start_col, second_end_row, second_end_col =
                  curr_start_row, curr_start_col, curr_end_row, curr_end_col
                cursor_follows_first = true -- cursor follows to target (first)
              end

              -- Perform replacements in order (later position first)
              vim.api.nvim_buf_set_text(
                0,
                first_start_row,
                first_start_col,
                first_end_row,
                first_end_col,
                vim.split(first_text, '\n')
              )
              vim.api.nvim_buf_set_text(
                0,
                second_start_row,
                second_start_col,
                second_end_row,
                second_end_col,
                vim.split(second_text, '\n')
              )

              -- Move cursor to follow the swapped element
              local new_cursor_row, new_cursor_col
              if cursor_follows_first then
                new_cursor_row = first_start_row + cursor_offset_row
                new_cursor_col = first_start_col + cursor_offset_col
              else
                new_cursor_row = second_start_row + cursor_offset_row
                new_cursor_col = second_start_col + cursor_offset_col
              end

              -- Ensure cursor position is valid
              local line_count = vim.api.nvim_buf_line_count(0)
              if new_cursor_row >= line_count then new_cursor_row = line_count - 1 end
              if new_cursor_row < 0 then new_cursor_row = 0 end

              local line_text = vim.api.nvim_buf_get_lines(0, new_cursor_row, new_cursor_row + 1, false)[1] or ''
              if new_cursor_col >= #line_text then new_cursor_col = math.max(0, #line_text - 1) end
              if new_cursor_col < 0 then new_cursor_col = 0 end

              vim.api.nvim_win_set_cursor(0, { new_cursor_row + 1, new_cursor_col }) -- +1 because cursor is 1-indexed

              return true, 'array element'
            end
          end
        end
        return false, nil

        -- Check for class field context - use manual node swapping
      elseif string.find(hierarchy_str, 'field_declaration') then
        -- Use manual field swapping instead of text objects
        local field_declaration = nil
        local node = cursor_node
        while node do
          if node:type() == 'field_declaration' then
            field_declaration = node
            break
          end
          node = node:parent()
        end

        if field_declaration then
          local class_body = field_declaration:parent()
          if class_body and class_body:type() == 'class_body' then
            local field_declarations = {}
            local current_index = nil

            for i = 0, class_body:child_count() - 1 do
              local child = class_body:child(i)
              if child and child:type() == 'field_declaration' then
                table.insert(field_declarations, child)
                if child == field_declaration then current_index = #field_declarations end
              end
            end

            if current_index then
              local target_index = dir == 'next' and current_index + 1 or current_index - 1
              if target_index >= 1 and target_index <= #field_declarations then
                local current_field = field_declarations[current_index]
                local target_field = field_declarations[target_index]

                local current_text = vim.treesitter.get_node_text(current_field, 0)
                local target_text = vim.treesitter.get_node_text(target_field, 0)

                local curr_start_row, curr_start_col, curr_end_row, curr_end_col = current_field:range()
                local target_start_row, target_start_col, target_end_row, target_end_col = target_field:range()

                -- Store cursor position relative to current field
                local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
                local cursor_offset_row = cursor_row - 1 - curr_start_row -- Convert to 0-indexed
                local cursor_offset_col = cursor_col - curr_start_col

                -- Determine which replacement to do first based on position
                -- Always replace the later one first to avoid coordinate shifts
                local first_field, second_field, first_text, second_text
                local first_start_row, first_start_col, first_end_row, first_end_col
                local second_start_row, second_start_col, second_end_row, second_end_col
                local cursor_follows_first = false

                if
                  curr_start_row > target_start_row
                  or (curr_start_row == target_start_row and curr_start_col > target_start_col)
                then
                  -- Current is after target, so replace current first
                  first_field, second_field = current_field, target_field
                  first_text, second_text = target_text, current_text
                  first_start_row, first_start_col, first_end_row, first_end_col =
                    curr_start_row, curr_start_col, curr_end_row, curr_end_col
                  second_start_row, second_start_col, second_end_row, second_end_col =
                    target_start_row, target_start_col, target_end_row, target_end_col
                  cursor_follows_first = false -- cursor follows to target (second)
                else
                  -- Target is after current, so replace target first
                  first_field, second_field = target_field, current_field
                  first_text, second_text = current_text, target_text
                  first_start_row, first_start_col, first_end_row, first_end_col =
                    target_start_row, target_start_col, target_end_row, target_end_col
                  second_start_row, second_start_col, second_end_row, second_end_col =
                    curr_start_row, curr_start_col, curr_end_row, curr_end_col
                  cursor_follows_first = true -- cursor follows to target (first)
                end

                -- Perform replacements in order (later position first)
                vim.api.nvim_buf_set_text(
                  0,
                  first_start_row,
                  first_start_col,
                  first_end_row,
                  first_end_col,
                  vim.split(first_text, '\n')
                )
                vim.api.nvim_buf_set_text(
                  0,
                  second_start_row,
                  second_start_col,
                  second_end_row,
                  second_end_col,
                  vim.split(second_text, '\n')
                )

                -- Move cursor to follow the swapped field
                local new_cursor_row, new_cursor_col
                if cursor_follows_first then
                  new_cursor_row = first_start_row + cursor_offset_row
                  new_cursor_col = first_start_col + cursor_offset_col
                else
                  new_cursor_row = second_start_row + cursor_offset_row
                  new_cursor_col = second_start_col + cursor_offset_col
                end

                -- Ensure cursor position is valid
                local line_count = vim.api.nvim_buf_line_count(0)
                if new_cursor_row >= line_count then new_cursor_row = line_count - 1 end
                if new_cursor_row < 0 then new_cursor_row = 0 end

                local line_text = vim.api.nvim_buf_get_lines(0, new_cursor_row, new_cursor_row + 1, false)[1] or ''
                if new_cursor_col >= #line_text then new_cursor_col = math.max(0, #line_text - 1) end
                if new_cursor_col < 0 then new_cursor_col = 0 end

                vim.api.nvim_win_set_cursor(0, { new_cursor_row + 1, new_cursor_col }) -- +1 because cursor is 1-indexed

                return true, 'class field'
              end
            end
          end
        end
        return false, nil

        -- Check for HTML attribute context - use manual node swapping
      elseif string.find(hierarchy_str, 'attribute') and string.find(hierarchy_str, 'start_tag') then
        -- Use manual attribute swapping for HTML
        local attribute = nil
        local start_tag = nil

        -- Walk up the tree to find attribute and start_tag
        local node = cursor_node
        while node do
          if node:type() == 'attribute' then
            attribute = node
          elseif node:type() == 'start_tag' then
            start_tag = node
            break
          end
          node = node:parent()
        end

        if attribute and start_tag then
          local attributes = {}
          local current_index = nil

          -- Find all attributes in the start_tag
          for i = 0, start_tag:child_count() - 1 do
            local child = start_tag:child(i)
            if child and child:type() == 'attribute' then
              table.insert(attributes, child)
              if child == attribute then current_index = #attributes end
            end
          end

          if current_index then
            local target_index = dir == 'next' and current_index + 1 or current_index - 1
            if target_index >= 1 and target_index <= #attributes then
              local current_attr = attributes[current_index]
              local target_attr = attributes[target_index]

              local current_text = vim.treesitter.get_node_text(current_attr, 0)
              local target_text = vim.treesitter.get_node_text(target_attr, 0)

              local curr_start_row, curr_start_col, curr_end_row, curr_end_col = current_attr:range()
              local target_start_row, target_start_col, target_end_row, target_end_col = target_attr:range()

              -- Store cursor position relative to current attribute
              local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
              local cursor_offset_row = cursor_row - 1 - curr_start_row -- Convert to 0-indexed
              local cursor_offset_col = cursor_col - curr_start_col

              -- Determine which replacement to do first based on position
              -- Always replace the later one first to avoid coordinate shifts
              local first_attr, second_attr, first_text, second_text
              local first_start_row, first_start_col, first_end_row, first_end_col
              local second_start_row, second_start_col, second_end_row, second_end_col
              local cursor_follows_first = false

              if
                curr_start_row > target_start_row
                or (curr_start_row == target_start_row and curr_start_col > target_start_col)
              then
                -- Current is after target, so replace current first
                first_attr, second_attr = current_attr, target_attr
                first_text, second_text = target_text, current_text
                first_start_row, first_start_col, first_end_row, first_end_col =
                  curr_start_row, curr_start_col, curr_end_row, curr_end_col
                second_start_row, second_start_col, second_end_row, second_end_col =
                  target_start_row, target_start_col, target_end_row, target_end_col
                cursor_follows_first = false -- cursor follows to target (second)
              else
                -- Target is after current, so replace target first
                first_attr, second_attr = target_attr, current_attr
                first_text, second_text = current_text, target_text
                first_start_row, first_start_col, first_end_row, first_end_col =
                  target_start_row, target_start_col, target_end_row, target_end_col
                second_start_row, second_start_col, second_end_row, second_end_col =
                  curr_start_row, curr_start_col, curr_end_row, curr_end_col
                cursor_follows_first = true -- cursor follows to target (first)
              end

              -- Perform replacements in order (later position first)
              vim.api.nvim_buf_set_text(
                0,
                first_start_row,
                first_start_col,
                first_end_row,
                first_end_col,
                vim.split(first_text, '\n')
              )
              vim.api.nvim_buf_set_text(
                0,
                second_start_row,
                second_start_col,
                second_end_row,
                second_end_col,
                vim.split(second_text, '\n')
              )

              -- Move cursor to follow the swapped attribute
              local new_cursor_row, new_cursor_col
              if cursor_follows_first then
                new_cursor_row = first_start_row + cursor_offset_row
                new_cursor_col = first_start_col + cursor_offset_col
              else
                new_cursor_row = second_start_row + cursor_offset_row
                new_cursor_col = second_start_col + cursor_offset_col
              end

              -- Ensure cursor position is valid
              local line_count = vim.api.nvim_buf_line_count(0)
              if new_cursor_row >= line_count then new_cursor_row = line_count - 1 end
              if new_cursor_row < 0 then new_cursor_row = 0 end

              local line_text = vim.api.nvim_buf_get_lines(0, new_cursor_row, new_cursor_row + 1, false)[1] or ''
              if new_cursor_col >= #line_text then new_cursor_col = math.max(0, #line_text - 1) end
              if new_cursor_col < 0 then new_cursor_col = 0 end

              vim.api.nvim_win_set_cursor(0, { new_cursor_row + 1, new_cursor_col }) -- +1 because cursor is 1-indexed

              return true, 'HTML attribute'
            end
          end
        end
        return false, nil

        -- Check for parameter context
      elseif string.find(hierarchy_str, 'parameter') or string.find(hierarchy_str, 'argument_list') then
        table.insert(swap_targets, { '@parameter.inner', 'parameter' })
        table.insert(swap_targets, { '@argument.outer', 'argument' })

        -- Default fallback
      else
        table.insert(swap_targets, { '@parameter.inner', 'parameter' })
        table.insert(swap_targets, { '@argument.outer', 'argument' })
        table.insert(swap_targets, { '@statement.outer', 'statement' })
        table.insert(swap_targets, { '@assignment.outer', 'assignment' })
        table.insert(swap_targets, { '@function.outer', 'function' })
        table.insert(swap_targets, { '@call.outer', 'function call' })
      end

      local success = false
      local swapped_type = nil

      for _, target in ipairs(swap_targets) do
        local text_object, description = target[1], target[2]
        local ok

        print('Trying:', text_object, '(', description, ')')
        if dir == 'next' then
          ok = ts_swap.swap_next(text_object)
        else
          ok = ts_swap.swap_previous(text_object)
        end

        if ok then
          success = true
          swapped_type = description
          print('Successfully swapped:', text_object, '(', description, ')')
          break -- Stop after first successful swap
        end
      end

      -- Provide visual feedback
      if success then
        local direction = dir == 'next' and 'forward' or 'backward'
        vim.notify(string.format('Swapped %s %s', swapped_type, direction), vim.log.levels.INFO, {
          title = 'Smart Swap',
          timeout = 1000,
        })
      else
        vim.notify('No swappable text objects found at cursor position', vim.log.levels.WARN, {
          title = 'Smart Swap',
          timeout = 2000,
        })
      end

      return success
    end

    -- Smart swap keymaps - context-aware swapping with cursor movement
    vim.keymap.set('n', '<leader><Down>', function() smart_swap('next') end, {
      desc = 'Smart swap next: arrays → fields → HTML attributes → parameters → functions (cursor follows)',
      silent = true,
    })

    vim.keymap.set('n', '<leader><Up>', function() smart_swap('prev') end, {
      desc = 'Smart swap previous: arrays → fields → HTML attributes → parameters → functions (cursor follows)',
      silent = true,
    })
  end,
}
