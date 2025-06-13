-- Enhanced Neovim Session Management
-- Uses persistence.nvim for robust, directory-based session persistence
-- Automatically saves/restores sessions per project directory with no manual intervention
return {
  'folke/persistence.nvim',
  event = 'VimEnter',
  priority = 100,
  opts = {
    -- Session storage directory (XDG compliant with better project isolation)
    dir = vim.fn.expand(vim.fn.stdpath('data') .. '/sessions/'),

    -- Session options to save/restore (matches vim sessionoptions exactly)
    options = {
      'blank',
      'buffers',
      'curdir',
      'folds',
      'help',
      'tabpages',
      'winsize',
      'winpos',
      'terminal',
      'localoptions',
    },

    -- Enhanced cleanup before saving session
    pre_save = function()
      -- Store current working directory for logging
      local cwd = vim.fn.getcwd()

      -- Close all floating windows to avoid restore issues
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= '' then pcall(vim.api.nvim_win_close, win, false) end
      end

      -- Close problematic buffer types that shouldn't be persisted
      local problematic_buftypes = { 'help', 'quickfix', 'terminal', 'prompt', 'nofile', 'acwrite' }

      local problematic_filetypes = {
        'gitcommit',
        'gitrebase',
        'trouble',
        'Trouble',
        'neo-tree',
        'startify',
        'TelescopePrompt',
        'lazy',
        'mason',
        'oil',
        'NvimTree',
      }

      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) then
          local buftype = vim.api.nvim_get_option_value('buftype', {
            buf = buf,
          })
          local filetype = vim.api.nvim_get_option_value('filetype', {
            buf = buf,
          })
          local bufname = vim.api.nvim_buf_get_name(buf)

          -- Skip unnamed buffers and problematic types
          local should_close = vim.tbl_contains(problematic_buftypes, buftype)
            or vim.tbl_contains(problematic_filetypes, filetype)
            or (bufname == '' and buftype == '')

          if should_close then pcall(vim.api.nvim_buf_delete, buf, {
            force = true,
          }) end
        end
      end

      -- Save views for all remaining buffers to preserve folds and cursor positions
      vim.cmd('silent! wall') -- Save all buffers
      vim.cmd('silent! mkview!') -- Save current view
    end,

    -- Enhanced callback after loading session
    post_open = function()
      local cwd = vim.fn.getcwd()

      -- Restore cursor positions and folds for all buffers
      vim.schedule(function()
        -- Restore cursor position
        vim.cmd('silent! normal! g`"')

        -- Load views to restore folds and cursor positions
        vim.cmd('silent! loadview')

        -- Refresh file tree if it exists and we're in a valid project
        if vim.fn.exists(':NvimTreeOpen') == 2 then
          vim.cmd('NvimTreeRefresh')
        elseif vim.fn.exists(':Neotree') == 2 then
          vim.cmd('Neotree filesystem reveal')
        end

        -- Refresh any LSP diagnostics
        vim.diagnostic.reset()
        vim.schedule(function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
              vim.cmd('silent! e')
              break
            end
          end
        end)
      end)
    end,
  },

  -- Optional key mappings for manual session management (can be removed if not needed)
  keys = {
    {
      '<leader>Sr',
      function()
        require('persistence').load()
        vim.notify('Session restored for: ' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t'))
      end,
      desc = 'Restore session for current directory',
    },
    {
      '<leader>Sl',
      function()
        require('persistence').load({
          last = true,
        })
        vim.notify('Last session restored')
      end,
      desc = 'Load last session',
    },
    {
      '<leader>Ss',
      function()
        require('persistence').save()
        vim.notify('Session saved for: ' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t'))
      end,
      desc = 'Save current session',
    },
    {
      '<leader>Sd',
      function()
        require('persistence').stop()
        vim.notify('Session persistence disabled for this session')
      end,
      desc = 'Stop session persistence',
    },
  },

  init = function()
    -- Debug function to help troubleshoot
    local function debug_log(message)
      if vim.g.persistence_debug then vim.notify('Persistence: ' .. message, vim.log.levels.INFO) end
    end

    -- Function to check if we have meaningful buffers
    local function has_meaningful_buffers()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_is_valid(buf) then
          local buftype = vim.api.nvim_get_option_value('buftype', {
            buf = buf,
          })
          local bufname = vim.api.nvim_buf_get_name(buf)

          -- Count as meaningful if it's a normal file buffer with a real path
          if buftype == '' and bufname ~= '' and not bufname:match('^/tmp/') and vim.fn.filereadable(bufname) == 1 then
            return true
          end
        end
      end
      return false
    end

    -- Enhanced auto-restore session when starting nvim
    vim.api.nvim_create_autocmd('VimEnter', {
      group = vim.api.nvim_create_augroup('PersistenceAutoRestore', {
        clear = true,
      }),
      callback = function()
        debug_log('VimEnter triggered')

        -- Get command line arguments
        local argc = vim.fn.argc()
        local argv = vim.fn.argv()
        local cwd = vim.fn.getcwd()

        debug_log('argc: ' .. argc .. ', cwd: ' .. cwd)
        debug_log('argv: ' .. vim.inspect(argv))
        debug_log('started_by_dashboard: ' .. tostring(vim.g.started_by_dashboard))
        debug_log('NVIM env: ' .. tostring(vim.env.NVIM))
        debug_log('started_with_stdin: ' .. tostring(vim.g.started_with_stdin))

        -- Only restore if:
        -- 1. Exactly 1 argument was passed
        -- 2. That argument is "." (current directory)
        -- 3. Not in nested nvim instance
        -- 4. Not reading from stdin
        local should_restore = argc == 1 and argv[1] == '.' and not vim.env.NVIM and not vim.g.started_with_stdin

        if should_restore then
          -- Check if a session exists for current directory
          local session_file = require('persistence').current()
          debug_log('Session file: ' .. tostring(session_file))

          if session_file and vim.fn.filereadable(session_file) == 1 then
            -- Delete any unnamed/empty buffers before restoring session
            local buffers = vim.api.nvim_list_bufs()
            for _, buf in ipairs(buffers) do
              if vim.api.nvim_buf_is_loaded(buf) then
                local bufname = vim.api.nvim_buf_get_name(buf)
                local buftype = vim.api.nvim_get_option_value('buftype', {
                  buf = buf,
                })
                local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

                -- Delete if it's an unnamed, empty buffer
                if bufname == '' and buftype == '' and #lines == 1 and lines[1] == '' then
                  debug_log('Deleting unnamed buffer: ' .. buf)
                  pcall(vim.api.nvim_buf_delete, buf, {
                    force = true,
                  })
                end
              end
            end

            -- Delay the restore to ensure Neovim is fully loaded
            vim.defer_fn(function()
              local success = pcall(function() require('persistence').load() end)

              if success then
                vim.notify('Session restored for: ' .. vim.fn.fnamemodify(cwd, ':t'), vim.log.levels.INFO)
                debug_log('Session restored successfully')
              else
                debug_log('Failed to restore session')
              end
            end, 100)
          else
            debug_log('No session file found - cleaning up for fresh start')

            -- No session exists, clean up any buffers and start fresh
            vim.defer_fn(function()
              local buffers = vim.api.nvim_list_bufs()
              for _, buf in ipairs(buffers) do
                if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_is_valid(buf) then
                  local bufname = vim.api.nvim_buf_get_name(buf)
                  local buftype = vim.api.nvim_get_option_value('buftype', {
                    buf = buf,
                  })

                  -- Delete any buffer that's not a special buffer type
                  -- This includes the directory buffer that gets created
                  if buftype == '' or bufname:match('/$') then
                    debug_log('Deleting buffer for fresh start: ' .. buf .. ' (' .. bufname .. ')')
                    pcall(vim.api.nvim_buf_delete, buf, {
                      force = true,
                    })
                  end
                end
              end

              -- Start with clean empty buffer for 'nvim .' with no session
              vim.notify('No session found for: ' .. vim.fn.fnamemodify(cwd, ':t'), vim.log.levels.INFO)
            end, 50)
          end
        else
          debug_log('Session restoration not triggered - normal nvim startup')
          -- For 'nvim' without arguments or with file arguments, just start normally
          -- No special handling needed - let nvim start with its normal behavior
        end
      end,
      nested = true,
    })

    -- Simplified auto-save session on exit
    vim.api.nvim_create_autocmd('VimLeavePre', {
      group = vim.api.nvim_create_augroup('PersistenceAutoSave', {
        clear = true,
      }),
      callback = function()
        debug_log('VimLeavePre triggered')

        -- Don't save in nested nvim instances
        if vim.env.NVIM then
          debug_log('Skipping save - nested nvim instance')
          return
        end

        -- Check if we should save
        if has_meaningful_buffers() then
          local cwd = vim.fn.getcwd()
          debug_log('Saving session for: ' .. cwd)

          local success = pcall(function() require('persistence').save() end)

          if success then
            print('Session saved for: ' .. vim.fn.fnamemodify(cwd, ':t'))
            debug_log('Session saved successfully')
          else
            print('Failed to save session for: ' .. vim.fn.fnamemodify(cwd, ':t'))
            debug_log('Failed to save session')
          end
        else
          debug_log('No meaningful buffers - skipping save')
        end
      end,
    })

    -- Detect stdin to avoid auto-restore when using pipes
    vim.api.nvim_create_autocmd('StdinReadPre', {
      group = vim.api.nvim_create_augroup('PersistenceStdinDetect', {
        clear = true,
      }),
      callback = function()
        vim.g.started_with_stdin = true
        debug_log('Stdin detected - disabling auto-restore')
      end,
    })

    -- Optional: Auto-save on directory change
    vim.api.nvim_create_autocmd('DirChanged', {
      group = vim.api.nvim_create_augroup('PersistenceDirChange', {
        clear = true,
      }),
      callback = function(ev)
        debug_log('Directory changed from ' .. tostring(ev.file) .. ' to ' .. vim.fn.getcwd())

        -- Save session for the old directory if we had meaningful buffers
        if has_meaningful_buffers() then
          vim.schedule(function()
            pcall(function() require('persistence').save() end)
            debug_log('Session saved due to directory change')
          end)
        end
      end,
    })

    -- Optional: Periodic auto-save (every 5 minutes after buffer writes)
    local last_save_time = 0
    vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
      group = vim.api.nvim_create_augroup('PersistencePeriodicSave', {
        clear = true,
      }),
      callback = function()
        local current_time = vim.fn.localtime()
        if current_time - last_save_time > 300 then -- 5 minutes
          last_save_time = current_time

          if has_meaningful_buffers() and require('persistence').current() then
            vim.schedule(function()
              pcall(function() require('persistence').save() end)
              debug_log('Periodic session save completed')
            end)
          end
        end
      end,
    })

    -- User commands for easy testing and debugging
    vim.api.nvim_create_user_command('PersistenceTest', function()
      local current_session = require('persistence').current()
      local cwd = vim.fn.getcwd()
      local argc = vim.fn.argc()
      local argv = vim.fn.argv()

      print('=== Persistence Test ===')
      print('Current directory: ' .. cwd)
      print('Session file: ' .. (current_session or 'none'))
      print('Session exists: ' .. tostring(current_session and vim.fn.filereadable(current_session) == 1))
      print('Arguments count: ' .. argc)
      print('Arguments: ' .. vim.inspect(argv))
      print('Has meaningful buffers: ' .. tostring(has_meaningful_buffers()))
      print('Nested nvim: ' .. tostring(vim.env.NVIM ~= nil))
      print('Started by dashboard: ' .. tostring(vim.g.started_by_dashboard))
      print('Started with stdin: ' .. tostring(vim.g.started_with_stdin))

      -- List current buffers
      print('\n=== Current Buffers ===')
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          local bufname = vim.api.nvim_buf_get_name(buf)
          local buftype = vim.api.nvim_get_option_value('buftype', {
            buf = buf,
          })
          local filetype = vim.api.nvim_get_option_value('filetype', {
            buf = buf,
          })
          print(
            'Buffer '
              .. buf
              .. ': '
              .. (bufname ~= '' and bufname or '[No Name]')
              .. ' (buftype: '
              .. buftype
              .. ', filetype: '
              .. filetype
              .. ')'
          )
        end
      end
    end, {
      desc = 'Test session restoration and show current state',
    })

    vim.api.nvim_create_user_command('PersistenceDebug', function()
      vim.g.persistence_debug = not vim.g.persistence_debug
      local status = vim.g.persistence_debug and 'enabled' or 'disabled'
      vim.notify('Persistence debug logging ' .. status, vim.log.levels.INFO)
    end, {
      desc = 'Toggle persistence debug logging',
    })
  end,
}
