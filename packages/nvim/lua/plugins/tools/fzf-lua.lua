-- FZF-Lua - Modern Neovim fuzzy finder with enhanced features
-- Keymaps: <leader>s* for all picker functions
return {
  'ibhagwan/fzf-lua',
  dependencies = { 'nvim-tree/nvim-web-devicons', 'nvim-treesitter/nvim-treesitter' },
  config = function()
    local fzf = require('fzf-lua')
    local actions = require('fzf-lua.actions')
    local notify = require('utils.notify')

    -- Helper function to clean file paths from fzf results
    local function clean_file_path(file)
      local cleaned = file

      -- Remove ANSI color codes
      cleaned = cleaned:gsub('\27%[[0-9;]*m', '')

      -- Remove git status indicators
      cleaned = cleaned:gsub('^%s*[MADRCU]%s*', '')

      -- Remove buffer numbers like [1] or [8]
      cleaned = cleaned:gsub('^%[%d+%]%s*', '')

      -- Remove file icons - keep removing non-filename characters at start
      while cleaned:len() > 0 and not cleaned:match('^[%w%._/-]') do
        cleaned = cleaned:gsub('^.%s*', '')
      end

      -- Remove line numbers
      cleaned = cleaned:gsub(':%d+:%d+$', '')
      cleaned = cleaned:gsub(':%d+$', '')

      -- Trim whitespace
      cleaned = cleaned:match('^%s*(.-)%s*$')

      -- Special handling for buffer entries - check if it's already a full path
      if cleaned:match('^/') then
        -- Already an absolute path, use as is
        return cleaned
      end

      -- Convert to absolute path
      return vim.fn.fnamemodify(cleaned, ':p')
    end


    -- Helper function to add files to quickfix list and open trouble
    local function add_files_to_quickfix(files)
      if not files or #files == 0 then
        notify.warn('add_files_to_quickfix', 'No files to add.')
        return
      end

      local qf_list = {}
      for _, entry in ipairs(files) do
        local absolute_path = clean_file_path(entry)
        table.insert(qf_list, {
          filename = absolute_path,
          lnum = 1,
          text = entry,
        })
      end

      vim.fn.setqflist(qf_list)
      vim.schedule(function() require('trouble').toggle('quickfix') end)
    end


    local function picker_opts(title, icon, extra_opts)
      local config = {
        prompt = icon and (icon .. ' ' .. title .. ': ') or (title .. ': '),
        winopts = {
          title = icon and (icon .. ' ' .. title) or title,
        },
        fzf_opts = {
          ['--info'] = 'inline',
          ['--layout'] = 'reverse',
        },
        silent = true,
      }

      if extra_opts then config = vim.tbl_deep_extend('force', config, extra_opts) end
      return config
    end


    fzf.setup({
      winopts = {
        height = 0.98,
        width = 1,
        border = false,
        preview = {
          horizontal = 'right:50%',
          layout = 'flex',
          flip_columns = 120,
          scrollbar = false,
          title_pos = 'center',
          delay = 100,
          wrap = true,
          border = false,
          vertical = 'up:45%',
        },
        on_create = function()
          -- Disable neovim's built-in Escape key handling in fzf windows
          vim.keymap.set('t', '<Esc>', '<Esc>', {
            buffer = true,
            nowait = true,
          })
        end,
      },
      keymap = {
        builtin = {
          ['<C-/>'] = 'toggle-preview',
          ['<C-l>'] = 'toggle-preview',
          ['<C-y>'] = 'yank+close',
          ['<Esc>'] = 'abort',
          ['<C-c>'] = 'abort',
          ['<PageUp>'] = 'preview-page-up',
          ['<PageDown>'] = 'preview-page-down',
          ['<CR>'] = 'accept',
        },
        fzf = {
          ['ctrl-f'] = 'preview-page-down',
          ['ctrl-b'] = 'preview-page-up',
          ['ctrl-a'] = 'toggle-all',
          ['ctrl-y'] = 'execute-silent(echo {+} | xclip -selection clipboard)',
          ['page-up'] = 'preview-page-up',
          ['page-down'] = 'preview-page-down',
          ['enter'] = 'accept',
          ['alt-t'] = 'accept',
          ['esc'] = 'abort',
        },
      },
      fzf_opts = {
        ['--bind'] = 'ctrl-c:abort,ctrl-y:execute-silent(echo {+} | xclip -selection clipboard),esc:abort,ctrl-/:toggle-preview,ctrl-l:toggle-preview,ctrl-d:preview-page-down,ctrl-u:preview-page-up,page-down:preview-page-down,page-up:preview-page-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up,ctrl-a:toggle-all',
        ['--cycle'] = '',
        ['--keep-right'] = '',
        ['--scroll-off'] = '5',
        ['--layout'] = 'reverse',
        ['--info'] = 'inline',
        ['--pointer'] = '▶',
        ['--marker'] = '✓',
        ['--prompt'] = '❯ ',
        ['--color'] = 'fg:#a9b1d6,bg:#1a1b26,preview-fg:#a9b1d6,preview-bg:#1a1b26,hl:#bb9af7:bold,fg+:#c0caf5:bold,bg+:#292e42,gutter:#1a1b26,hl+:#bb9af7:bold,query:#7aa2f7:bold,info:#e0af68,prompt:#7aa2f7,pointer:#7aa2f7,marker:#9ece6a:bold,spinner:#9ece6a,header:#9ece6a:bold,border:#1a1b26',
      },
      previewers = {
        builtin = {
          extensions = {
            ['png'] = { 'chafa' },
            ['jpg'] = { 'chafa' },
            ['jpeg'] = { 'chafa' },
            ['gif'] = { 'chafa' },
            ['ico'] = { 'chafa' },
            ['svg'] = { 'chafa' },
            ['webp'] = { 'chafa' },
            ['pdf'] = { 'pdftotext' },
            ['zip'] = { 'als' },
            ['tar'] = { 'als' },
            ['gz'] = { 'als' },
            ['7z'] = { 'als' },
            ['rar'] = { 'als' },
          },
        },
      },
      files = {
        resume = true,
        fd_opts = '--color=never --type f --hidden --follow --exclude .git --exclude node_modules',
        find_opts = '-type f -not -path \'*/.git/*\' -not -path \'*/node_modules/*\'',
        git_icons = true,
        file_icons = true,
        color_icons = true,
        find_command = 'fd',
      },
      buffers = {
        git_icons = true,
        file_icons = true,
        color_icons = true,
      },
      grep = {
        resume = true,
        rg_opts = '--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -g \'!.git\' -g \'!node_modules\'',
        git_icons = true,
        file_icons = true,
        color_icons = true,
        no_header = true,
        no_header_i = true,
        delimiter = ' │ ',
      },
      actions = {
        files = {
          ['default'] = actions.file_edit,
          ['alt-t'] = actions.file_tabedit,
          ['alt-v'] = actions.file_vsplit,
          ['alt-s'] = actions.file_split,
          ['alt-c'] = function(selected) add_files_to_quickfix(selected) end,
        },
        buffers = {
          ['default'] = actions.buf_edit,
          ['alt-t'] = actions.buf_tabedit,
          ['ctrl-v'] = actions.buf_vsplit,
          ['ctrl-s'] = actions.buf_split,
        },
      },
    })

    local function picker_opts(title, icon, extra_opts)
      local config = {
        prompt = icon and (icon .. ' ' .. title .. ': ') or (title .. ': '),
        winopts = {
          title = icon and (icon .. ' ' .. title) or title,
        },
        fzf_opts = {
          ['--info'] = 'inline',
          ['--layout'] = 'reverse',
        },
        silent = true,
      }

      if extra_opts then config = vim.tbl_deep_extend('force', config, extra_opts) end
      return config
    end

    -- Keymaps
    local keymaps = {
      { '<leader>sf', function() fzf.files(picker_opts('Find Files', '󰈞')) end, 'Find files' },
      {
        '<leader>sF',
        function()
          fzf.files(picker_opts('Find Files (All)', '󰈞', {
            fd_opts = '--color=never --type f --no-ignore --hidden --follow',
            find_opts = '-type f',
          }))
        end,
        'Find files (all/hidden)',
      },
      { '<leader>sg', function() fzf.live_grep(picker_opts('Live Grep', '󰩉')) end, 'Live grep' },
      {
        '<leader>sw',
        function() fzf.grep_cword(picker_opts('Grep Word', '󰩉')) end,
        'Grep word under cursor',
      },
      {
        '<leader>sb',
        function()
          fzf.buffers(picker_opts('Buffers', '󰈔', {
            winopts = {
              preview = {
                hidden = 'hidden',
              },
            },
          }))
        end,
        'Find buffers',
      },
      {
        '<leader>so',
        function()
          fzf.oldfiles(picker_opts('Recent Files', '󱋢', {
            cwd_only = true,
          }))
        end,
        'Recent files',
      },
      {
        '<leader>s.',
        function() fzf.oldfiles(picker_opts('Recent Files (All)', '󱋢')) end,
        'Recent files (all)',
      },
      {
        '<leader>s/',
        function() fzf.blines(picker_opts('Current Buffer Lines', '󰍉')) end,
        'Current buffer lines',
      },
      {
        '<leader>s?',
        function() fzf.grep_curbuf(picker_opts('Grep Current Buffer', '')) end,
        'Grep current buffer',
      },
      {
        '<leader>sl',
        function() fzf.lines(picker_opts('Lines in All Buffers', '󰍉')) end,
        'Lines in all buffers',
      },
      { '<leader>:', function() fzf.commands(picker_opts('Commands', '󰘳')) end, 'Commands' },
      { '<leader>sk', function() fzf.keymaps(picker_opts('Keymaps', '󰌋')) end, 'Keymaps' },
      { '<leader>sj', function() fzf.jumps(picker_opts('Jump List', '󰕰')) end, 'Jump list' },
      { '<leader>sH', function() fzf.help_tags(picker_opts('Help Tags', '󰋗')) end, 'Help tags' },
      { '<leader>sr', function() fzf.resume() end, 'Resume last search' },
      {
        '<leader>sGd',
        function() fzf.lsp_definitions(picker_opts('LSP Definitions', '󰒊')) end,
        'LSP definitions',
      },
      {
        '<leader>sGD',
        function() fzf.lsp_declarations(picker_opts('LSP Declarations', '󰒊')) end,
        'LSP declarations',
      },
      {
        '<leader>si',
        function() fzf.lsp_implementations(picker_opts('LSP Implementations', '󰒊')) end,
        'LSP implementations',
      },
      {
        '<leader>st',
        function() fzf.lsp_typedefs(picker_opts('LSP Type Definitions', '󰒊')) end,
        'LSP type definitions',
      },
      {
        '<leader>sR',
        function() fzf.lsp_references(picker_opts('LSP References', '󰒊')) end,
        'LSP references',
      },
      {
        '<leader>sS',
        function() fzf.lsp_document_symbols(picker_opts('Document Symbols', '󰒕')) end,
        'Document symbols',
      },
      {
        '<leader>sW',
        function() fzf.lsp_workspace_symbols(picker_opts('Workspace Symbols', '󰒕')) end,
        'Workspace symbols',
      },
      {
        '<leader>se',
        function() fzf.diagnostics_document(picker_opts('Buffer Diagnostics', '󰞏')) end,
        'Buffer diagnostics',
      },
      {
        '<leader>sE',
        function() fzf.diagnostics_workspace(picker_opts('Workspace Diagnostics', '󰞏')) end,
        'Workspace diagnostics',
      },
      { '<leader>sGf', function() fzf.git_files(picker_opts('Git Files', '󰊢')) end, 'Git files' },
      {
        '<leader>ss',
        function() fzf.git_status(picker_opts('Git Status', '󰊢')) end,
        'Git status',
      },
      {
        '<leader>sGc',
        function() fzf.git_commits(picker_opts('Git Commits', '󰊢')) end,
        'Git commits',
      },
      {
        '<leader>sGb',
        function() fzf.git_bcommits(picker_opts('Git Buffer Commits', '󰊢')) end,
        'Git buffer commits',
      },
      {
        '<leader>sGB',
        function() fzf.git_branches(picker_opts('Git Branches', '󰊢')) end,
        'Git branches',
      },
      {
        '<leader>sq',
        function() fzf.quickfix(picker_opts('Quickfix List', '󱖫')) end,
        'Quickfix list',
      },
      {
        '<leader>sQ',
        function() fzf.loclist(picker_opts('Location List', '󰌘')) end,
        'Location list',
      },
      {
        '<leader>sp',
        function()
          fzf.files(picker_opts('Project Files', '󰈞', {
            cwd = '/mnt/backup/code',
          }))
        end,
        'Project files',
      },
      {
        '<leader>sP',
        function()
          local input = vim.fn.input('Projects directory: ', '/mnt/backup/code', 'dir')
          if input ~= '' then
            fzf.files(picker_opts('Project Files', '󰈞', {
              cwd = input,
            }))
          end
        end,
        'Project files (choose directory)',
      },
      {
        '<leader><leader>',
        function()
          fzf.buffers(picker_opts('Buffers', '󰈔', {
            winopts = {
              preview = {
                hidden = 'hidden',
              },
            },
            actions = {
              ['default'] = actions.buf_edit,
              ['alt-t'] = actions.buf_tabedit,
              ['ctrl-v'] = actions.buf_vsplit,
              ['ctrl-s'] = actions.buf_split,
            },
          }))
        end,
        'Buffers (quick access)',
      },
      {
        '<C-S-f>',
        function() fzf.live_grep(picker_opts('Live Grep', '󰩉')) end,
        'Quick live grep',
      },
      { '<C-p>', function() fzf.files(picker_opts('Find Files', '󰈞')) end, 'Quick file finder' },
      {
        '\\',
        function()
          fzf.oldfiles(picker_opts('Recent Files in Project', '󰈞', {
            cwd_only = true,
          }))
        end,
        'Recent files in current project',
      },
      { '<leader>sc', function() fzf.tags(picker_opts('CTags', '󰓻')) end, 'CTags' },
      {
        '<leader>sy',
        function()
          local ok, yanky = pcall(require, 'yanky.history')
          if ok then
            local entries = yanky.all()
            local items = {}
            for i, entry in ipairs(entries) do
              local text = entry.regcontents
              if type(text) == 'table' then text = table.concat(text, '\n') end
              table.insert(items, {
                text = text,
                idx = i,
                regtype = entry.regtype,
              })
            end

            fzf.fzf_exec(function(cb)
              for _, item in ipairs(items) do
                cb(item.text)
              end
            end, {
              prompt = '󰆐 Yank History: ',
              actions = {
                ['default'] = function(selected)
                  local text = selected[1]
                  vim.fn.setreg('"', text)
                  vim.cmd('normal! ""p')
                end,
              },
            })
          else
            notify.warn('Yank History', 'Yank history not available')
          end
        end,
        'Yank history',
      },
      {
        '<leader>sY',
        function() fzf.files(picker_opts('Yank History', '󰆐')) end,
        'Yank history',
      },
      {
        '<leader>sn',
        function()
          local function get_messages()
            local messages = {}

            -- Method 1: Try noice message manager
            local manager_ok, manager = pcall(require, 'noice.message.manager')
            if manager_ok and manager.get then
              local manager_messages = manager.get({})
              if manager_messages and #manager_messages > 0 then
                for _, msg in ipairs(manager_messages) do
                  table.insert(messages, msg)
                end
              end
            end

            -- Method 2: Try noice API directly
            local noice_ok, noice = pcall(require, 'noice')
            if noice_ok and noice.get_messages then
              local noice_messages = noice.get_messages()
              if noice_messages and #noice_messages > 0 then
                for _, msg in ipairs(noice_messages) do
                  table.insert(messages, msg)
                end
              end
            end

            -- Method 3: Try accessing noice config
            if #messages == 0 and noice_ok then
              local config_ok, config = pcall(require, 'noice.config')
              if config_ok and config.messages then
                for _, msg in ipairs(config.messages) do
                  table.insert(messages, msg)
                end
              end
            end

            -- Method 4: Try notify history as fallback
            if #messages == 0 and _G.notification_utils then
              local history = _G.notification_utils.get_history()
              if history and #history > 0 then
                for _, entry in ipairs(history) do
                  table.insert(messages, {
                    content = entry.message,
                    level = entry.level,
                    time = entry.timestamp,
                    opts = entry.opts,
                  })
                end
              end
            end

            return messages
          end

          local messages = get_messages()

          if not messages or #messages == 0 then
            vim.notify('No messages found', vim.log.levels.INFO)
            return
          end

          -- Convert messages to display format
          local items = {}
          for i, msg in ipairs(messages) do
            local content = ''

            -- Enhanced content parsing
            if msg.content then
              if type(msg.content) == 'table' then
                -- Handle nested tables and different content structures
                local parts = {}
                for _, part in ipairs(msg.content) do
                  if type(part) == 'table' then
                    if part.text then
                      table.insert(parts, part.text)
                    elseif part.content then
                      table.insert(parts, tostring(part.content))
                    else
                      table.insert(parts, vim.inspect(part))
                    end
                  else
                    table.insert(parts, tostring(part))
                  end
                end
                content = table.concat(parts, ' ')
              else
                content = tostring(msg.content)
              end
            elseif msg.message then
              content = tostring(msg.message)
            end

            if content and content ~= '' then
              -- Add severity prefix for better identification
              local prefix = ''
              if msg.level then
                local level_map = {
                  [vim.log.levels.ERROR] = '󰅚 ERROR',
                  [vim.log.levels.WARN] = '󰀪 WARN',
                  [vim.log.levels.INFO] = '󰋽 INFO',
                  [vim.log.levels.DEBUG] = '󰃤 DEBUG',
                }
                prefix = level_map[msg.level] or '󰋽 INFO'
              else
                prefix = '󰋽 INFO'
              end

              local display_text = prefix .. ': ' .. content
              table.insert(items, {
                text = display_text,
                original = content,
                level = msg.level,
                time = msg.time,
                index = i,
              })
            end
          end

          if #items == 0 then
            vim.notify('No displayable messages found', vim.log.levels.INFO)
            return
          end

          fzf.fzf_exec(function(cb)
            for _, item in ipairs(items) do
              cb(item.text)
            end
          end, {
            prompt = '󰍶 Noice Messages (' .. #items .. '): ',
            previewer = {
              type = 'cmd',
              fn = function(entry)
                -- Find the original item for preview
                local selected_item = nil
                for _, item in ipairs(items) do
                  if item.text == entry then
                    selected_item = item
                    break
                  end
                end

                if selected_item then
                  -- Format the preview content
                  local level_name = 'unknown'
                  if selected_item.level then
                    for name, level in pairs(vim.log.levels) do
                      if level == selected_item.level then
                        level_name = name:lower()
                        break
                      end
                    end
                  end

                  local preview_lines = {
                    '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
                    '📋 MESSAGE DETAILS',
                    '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
                    '',
                    '🔸 Level: ' .. level_name,
                    '🔸 Time: ' .. (selected_item.time or 'unknown'),
                    '🔸 Index: ' .. (selected_item.index or 'unknown'),
                    '',
                    '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
                    '📄 FULL MESSAGE',
                    '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
                    '',
                  }

                  -- Split the message into lines for better formatting
                  local message_lines = vim.split(selected_item.original, '\n')
                  for _, line in ipairs(message_lines) do
                    table.insert(preview_lines, line)
                  end

                  table.insert(preview_lines, '')
                  table.insert(
                    preview_lines,
                    '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
                  )
                  table.insert(preview_lines, 'Press Enter to view details | Ctrl-Y to copy message')
                  table.insert(
                    preview_lines,
                    '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
                  )

                  return table.concat(preview_lines, '\n')
                end

                return 'No preview available'
              end,
            },
            winopts = {
              title = '󰍶 Noice Messages',
              preview = {
                layout = 'vertical',
                vertical = 'down:50%',
                wrap = true,
              },
            },
            actions = {
              ['default'] = function(selected)
                if not selected[1] then return end

                -- Find the original item
                local selected_item = nil
                for _, item in ipairs(items) do
                  if item.text == selected[1] then
                    selected_item = item
                    break
                  end
                end

                if selected_item then
                  -- Show message details
                  local level_name = 'unknown'
                  if selected_item.level then
                    for name, level in pairs(vim.log.levels) do
                      if level == selected_item.level then
                        level_name = name
                        break
                      end
                    end
                  end

                  local details = {
                    'Message: ' .. selected_item.original,
                    'Level: ' .. level_name,
                    'Time: ' .. (selected_item.time or 'unknown'),
                  }
                  vim.notify(table.concat(details, '\n'), vim.log.levels.INFO, {
                    title = 'Message Details',
                  })
                end
              end,
              ['ctrl-y'] = function(selected)
                if not selected[1] then return end

                -- Find the original item and copy to clipboard
                local selected_item = nil
                for _, item in ipairs(items) do
                  if item.text == selected[1] then
                    selected_item = item
                    break
                  end
                end

                if selected_item then
                  vim.fn.setreg('+', selected_item.original)
                  vim.fn.setreg('"', selected_item.original)
                  vim.notify('Message copied to clipboard', vim.log.levels.INFO, {
                    title = 'Copy Success',
                  })
                end
              end,
            },
            fzf_opts = {
              ['--header'] = 'Enter: View Details | Ctrl-Y: Copy Message | Ctrl-/: Toggle Preview',
            },
          })
        end,
        'Noice Messages',
      },
    }

    for _, keymap in ipairs(keymaps) do
      vim.keymap.set('n', keymap[1], keymap[2], {
        desc = keymap[3],
      })
    end

    vim.api.nvim_create_user_command(
      'FzfConfig',
      function()
        fzf.files({
          prompt = '󰈞 Neovim Config: ',
          cwd = vim.fn.stdpath('config'),
        })
      end,
      {
        desc = 'Find files in Neovim config',
      }
    )

    -- Terminal mode mapping for Escape
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'fzf',
      callback = function()
        vim.keymap.set('t', '<Esc>', '<C-c>', {
          buffer = true,
          nowait = true,
        })
      end,
    })
  end,
}
