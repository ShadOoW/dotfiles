return {
  'sidebar-nvim/sidebar.nvim',
  config = function()
    require('sidebar-nvim').setup({
      disable_default_keybindings = 1,
      bindings = {
        ['<CR>'] = function(line, col)
          local ok, current_line = pcall(vim.api.nvim_get_current_line)
          if not ok or not current_line then return end

          -- Handle buffer selection from buffers section
          if current_line:match('^%s*%d+:') then
            local buf_num = current_line:match('^%s*(%d+):')
            if buf_num and tonumber(buf_num) then
              local success, _ = pcall(vim.cmd, 'buffer ' .. buf_num)
              if success then return end
            end
          end

          -- Handle file selection from files section
          -- Get the file path from the current line
          local file_path = current_line:match('^%s*(.+)$')
          if file_path and file_path ~= '' then
            -- Remove any leading icons or whitespace
            file_path = file_path:gsub('^%s*[^%w/~%.]*%s*', '')

            -- If it looks like a file path, try to open it
            if file_path:match('[%w/~%.]') then
              -- Get the current working directory from sidebar context
              local ok_cwd, cwd = pcall(vim.fn.getcwd)
              if not ok_cwd then return end

              local full_path = vim.fn.fnamemodify(cwd .. '/' .. file_path, ':p')

              -- Check if file exists before trying to open
              if vim.fn.filereadable(full_path) == 1 then
                pcall(vim.cmd, 'edit ' .. vim.fn.fnameescape(full_path))
              elseif vim.fn.isdirectory(full_path) == 1 then
                pcall(vim.cmd, 'cd ' .. vim.fn.fnameescape(full_path))
                -- Refresh sidebar to show new directory
                pcall(require('sidebar-nvim').update)
              end
            end
          end
        end,
        ['<2-LeftMouse>'] = function(line, col)
          -- Reuse the same logic as <CR>
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
        end,
        ['o'] = function(line, col)
          -- Same as <CR>
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
        end,
        ['s'] = function(line, col)
          vim.cmd('split')
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
        end,
        ['v'] = function(line, col)
          vim.cmd('vsplit')
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
        end,
        ['t'] = function(line, col)
          vim.cmd('tabnew')
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
        end,
        ['q'] = function() require('sidebar-nvim').close() end,
      },
      open = true,
      side = 'right',
      initial_width = 35,
      hide_statusline = false,
      update_interval = 1000,
      sections = { 'buffers', 'files', 'git', 'diagnostics', 'symbols' },
      section_separator = { '', '-----', '' },
      section_title_separator = { '' },
      containers = {
        attach_shell = '/bin/zsh',
        show_all = true,
        interval = 5000,
      },
      datetime = {
        icon = '',
        format = '%a %b %d, %Y at %H:%M',
        clocks = { {
          name = 'local',
        } },
      },
      todos = {
        icon = '',
        ignored_paths = { '~/.config/nvim' },
        initially_closed = false,
      },
      git = {
        icon = '',
      },
      diagnostics = {
        icon = '',
      },
      buffers = {
        icon = '',
        ignored_buffers = {},
        sorting = 'name',
        show_numbers = true,
      },
      files = {
        icon = '',
        show_hidden = false,
        ignored_paths = { '%.git$' },
      },
      symbols = {
        icon = '󰠱',
      },
    })

    vim.api.nvim_create_autocmd('VimLeavePre', {
      group = vim.api.nvim_create_augroup('SidebarSession', {
        clear = true,
      }),
      callback = function()
        local sidebar_open = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.api.nvim_get_option_value('filetype', {
            buf = buf,
          })
          if ft == 'Sidebar' then
            sidebar_open = true
            break
          end
        end
        vim.g.sidebar_was_open = sidebar_open
      end,
    })

    -- Handle session restoration conflicts
    vim.api.nvim_create_autocmd('SessionLoadPost', {
      group = vim.api.nvim_create_augroup('SidebarSessionRestore', {
        clear = true,
      }),
      callback = function()
        -- Delay sidebar restoration to avoid conflicts with session restoration
        -- This works in tandem with the session plugin's sidebar restoration
        vim.defer_fn(function()
          if vim.g.sidebar_was_open then
            -- Additional safety check after session is completely loaded
            vim.schedule(function()
              vim.defer_fn(function()
                local sidebar_open = false
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  local buf = vim.api.nvim_win_get_buf(win)
                  if vim.api.nvim_buf_is_valid(buf) then
                    local ok, ft = pcall(vim.api.nvim_get_option_value, 'filetype', {
                      buf = buf,
                    })
                    if ok and ft == 'Sidebar' then
                      sidebar_open = true
                      break
                    end
                  end
                end

                -- Last resort restoration if session plugin didn't handle it
                if not sidebar_open then
                  pcall(require('sidebar-nvim').open)
                  vim.defer_fn(function() pcall(require('sidebar-nvim').update) end, 100)
                end
              end, 200) -- Final check delay
            end)
          end
        end, 1000) -- Long delay to be after session plugin restoration
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'SidebarNvimReady',
      callback = function()
        vim.opt_local.buflisted = false
        vim.opt_local.bufhidden = 'wipe'
        vim.opt_local.swapfile = false
      end,
    })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufAdd', 'BufDelete', 'BufWipeout' }, {
      group = vim.api.nvim_create_augroup('SidebarAutoRefresh', {
        clear = true,
      }),
      callback = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.api.nvim_get_option_value('filetype', {
            buf = buf,
          })
          if ft == 'Sidebar' then
            vim.schedule(function() require('sidebar-nvim').update() end)
            break
          end
        end
      end,
    })
  end,
}
