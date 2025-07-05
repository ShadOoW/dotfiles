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
      -- Clean the file path from icons, spaces, and buffer numbers
      local cleaned = string.match(file, '[a-zA-Z0-9/._-].*') or file
      cleaned = cleaned:match('%[%d+%]%s*(.+)') or cleaned
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

    -- Helper functions for harpoon integration
    local function add_to_harpoon(selected, opts)
      if not selected or #selected == 0 then return end
      local harpoon = require('harpoon')
      local absolute_path = clean_file_path(selected[1])

      -- Add to harpoon without closing picker
      vim.schedule(function()
        -- Get current cursor position from the buffer if it exists
        local row, col = 0, 0
        local bufnr = vim.fn.bufnr(absolute_path)
        if bufnr > 0 and vim.api.nvim_buf_is_loaded(bufnr) then
          local win = vim.fn.bufwinid(bufnr)
          if win > 0 then
            row = vim.api.nvim_win_get_cursor(win)[1] - 1
            col = vim.api.nvim_win_get_cursor(win)[2]
          end
        end

        -- Create proper harpoon item with full context
        local item = {
          value = absolute_path,
          context = {
            row = row,
            col = col,
            line = '',
            before = {},
            after = {},
            register_names = {},
            registers = {},
            length = 0,
          },
        }

        -- Try to get buffer content for context if buffer exists
        if bufnr > 0 and vim.api.nvim_buf_is_loaded(bufnr) then
          local lines = vim.api.nvim_buf_get_lines(bufnr, math.max(0, row - 2), row + 3, false)
          if #lines > 0 then
            item.context.line = lines[math.min(3, #lines)] or ''
            item.context.before = { lines[1] or '', lines[2] or '' }
            item.context.after = { lines[4] or '', lines[5] or '' }
            item.context.length = #item.context.line
          end
        end

        harpoon:list():add(item)
        notify.info('Harpoon', 'Added ' .. vim.fn.fnamemodify(absolute_path, ':t') .. ' to harpoon')
      end)

      if opts and opts.fn_post then opts.fn_post() end
      return false -- Return false to prevent picker from closing
    end

    local function remove_from_harpoon(selected, opts)
      if not selected or #selected == 0 then return end
      local harpoon = require('harpoon')
      local absolute_path = clean_file_path(selected[1])

      -- Remove from harpoon without closing picker
      vim.schedule(function()
        local list = harpoon:list()
        local idx = nil
        for i, item in ipairs(list:display()) do
          if item.value == absolute_path then
            idx = i
            break
          end
        end
        if idx then
          list:removeAt(idx)
          notify.info('Harpoon', 'Removed ' .. vim.fn.fnamemodify(absolute_path, ':t') .. ' from harpoon')
        end
      end)

      if opts and opts.fn_post then opts.fn_post() end
      return false -- Return false to prevent picker from closing
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
          ['<CR>'] = 'select',
          ['<Right>'] = 'toggle+down',
          ['<Left>'] = 'toggle+down',
        },
        fzf = {
          ['ctrl-f'] = 'preview-page-down',
          ['ctrl-b'] = 'preview-page-up',
          ['ctrl-a'] = 'toggle-all',
          ['ctrl-y'] = 'execute-silent(echo {+} | xclip -selection clipboard)',
          ['page-up'] = 'preview-page-up',
          ['page-down'] = 'preview-page-down',
          ['enter'] = 'select',
          ['alt-t'] = 'select',
          ['esc'] = 'abort',
          ['right'] = 'toggle+down',
          ['left'] = 'toggle+down',
        },
      },
      fzf_opts = {
        ['--bind'] = 'ctrl-c:abort,ctrl-y:execute-silent(echo {+} | xclip -selection clipboard),esc:abort,ctrl-/:toggle-preview,ctrl-l:toggle-preview,ctrl-d:preview-page-down,ctrl-u:preview-page-up,page-down:preview-page-down,page-up:preview-page-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up,ctrl-a:toggle-all,right:toggle+down,left:toggle+down',
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
        fd_opts = '--color=never --type f --hidden --follow --exclude .git --exclude node_modules',
        find_opts = '-type f -not -path \'*/.git/*\' -not -path \'*/node_modules/*\'',
        git_icons = true,
        file_icons = true,
        color_icons = true,
        find_command = 'fd',
      },
      grep = {
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
          ['ctrl-v'] = actions.file_vsplit,
          ['ctrl-s'] = actions.file_split,
          ['alt-c'] = function(selected) add_files_to_quickfix(selected) end,
          ['right'] = function(selected)
            add_to_harpoon(selected, {
              fn_post = function() end,
            })
          end,
          ['left'] = function(selected)
            remove_from_harpoon(selected, {
              fn_post = function() end,
            })
          end,
        },
        buffers = {
          ['default'] = actions.buf_edit,
          ['alt-t'] = actions.buf_tabedit,
          ['ctrl-v'] = actions.buf_vsplit,
          ['ctrl-s'] = actions.buf_split,
          ['right'] = function(selected)
            add_to_harpoon(selected, {
              fn_post = function() end,
            })
          end,
          ['left'] = function(selected)
            remove_from_harpoon(selected, {
              fn_post = function() end,
            })
          end,
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
        function() fzf.grep_curbuf(picker_opts('Grep Current Buffer', '󰍉')) end,
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

    -- Obsidian integration
    _G.fzf_select_book = function(books, callback)
      local items = vim.deepcopy(books)
      table.insert(items, '+ New Book...')

      fzf.fzf_exec(function(cb)
        for _, item in ipairs(items) do
          cb(item)
        end
      end, {
        prompt = '󱉟 Select or Create Book: ',
        actions = {
          ['default'] = function(selected)
            if not selected[1] then return end
            local choice = selected[1]

            if choice == '+ New Book...' then
              local obsidian = require('utils.obsidian')
              obsidian.ui.create_new_book(callback)
            else
              local obsidian = require('utils.obsidian')
              obsidian.ui.add_chapter_to_existing_book(choice, callback)
            end
          end,
        },
        winopts = {
          title = '󱉟 Obsidian Books',
          preview = {
            hidden = 'hidden',
          },
        },
      })
    end

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
