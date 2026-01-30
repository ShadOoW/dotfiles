-- Enhanced statusline configuration
-- Provides modern, contextual status information with clean design
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons', 'rcarriga/nvim-notify' },
  event = 'VeryLazy',
  config = function()
    local lualine = require('lualine')

    local function get_project_name()
      local cwd = vim.fn.getcwd()
      local project_name = vim.fn.fnamemodify(cwd, ':t')

      -- Java projects with Gradle
      if vim.fn.filereadable(cwd .. '/build.gradle') == 1 or vim.fn.filereadable(cwd .. '/settings.gradle') == 1 then
        return ' ' .. project_name
      end

      -- Java projects with Maven
      if vim.fn.filereadable(cwd .. '/pom.xml') == 1 then return ' ' .. project_name end

      -- Node.js projects
      if vim.fn.filereadable(cwd .. '/package.json') == 1 then return ' ' .. project_name end

      -- Rust projects
      if vim.fn.filereadable(cwd .. '/Cargo.toml') == 1 then return ' ' .. project_name end

      -- Python projects
      if
        vim.fn.filereadable(cwd .. '/pyproject.toml') == 1
        or vim.fn.filereadable(cwd .. '/setup.py') == 1
        or vim.fn.filereadable(cwd .. '/requirements.txt') == 1
      then
        return ' ' .. project_name
      end

      -- Git repositories
      if vim.fn.isdirectory(cwd .. '/.git') == 1 then return ' ' .. project_name end

      return ' ' .. project_name
    end

    local function get_lsp_status()
      local clients = vim.lsp.get_clients({
        bufnr = 0,
      })
      if #clients == 0 then return '' end

      local client_names = {}
      for _, client in pairs(clients) do
        table.insert(client_names, client.name)
      end

      return ' ' .. table.concat(client_names, ', ')
    end

    local function get_tag_status()
      local tag_file = vim.fn.expand('%:p:h') .. '/tags'
      if vim.fn.filereadable(tag_file) == 1 then
        local mtime = vim.fn.getftime(tag_file)
        local current_time = os.time()
        local age = current_time - mtime

        -- If tags are older than 1 hour, show updating status
        if age > 3600 then
          return ' Updating...'
        else
          return ' Tags Ready'
        end
      end
      return ''
    end

    local function java_version()
      if vim.bo.filetype == 'java' then return ' Java' end
      return ''
    end

    -- Custom components
    local function buffer_count()
      local buffers = vim.fn.len(vim.fn.getbufinfo({
        buflisted = 1,
        bufmodified = 0,
        fileloaded = 1, -- Only count file buffers
      }))
      return string.format(' %d', buffers)
    end

    -- Enhanced notification functions with severity filtering
    local function notification_error_count()
      -- Check if our notification utilities are available
      if not _G.notification_utils then return '' end

      local counts = _G.notification_utils.count_by_severity(300) -- Last 5 minutes
      local error_count = counts.error or 0

      if error_count == 0 then return '' end

      return string.format('E %d', error_count)
    end

    local function notification_warn_count()
      -- Check if our notification utilities are available
      if not _G.notification_utils then return '' end

      local counts = _G.notification_utils.count_by_severity(300) -- Last 5 minutes
      local warn_count = counts.warn or 0

      if warn_count == 0 then return '' end

      return string.format('W %d', warn_count)
    end

    -- Custom theme with improved contrast for better visibility
    local custom_theme = {
      normal = {
        a = {
          fg = '#1e1e2e',
          bg = '#89b4fa',
          gui = 'bold',
        },
        b = {
          fg = '#cdd6f4',
          bg = '#45475a',
        },
        c = {
          fg = '#bac2de',
          bg = '#313244',
        },
      },
      insert = {
        a = {
          fg = '#1e1e2e',
          bg = '#a6e3a1',
          gui = 'bold',
        },
        b = {
          fg = '#cdd6f4',
          bg = '#45475a',
        },
        c = {
          fg = '#bac2de',
          bg = '#313244',
        },
      },
      visual = {
        a = {
          fg = '#1e1e2e',
          bg = '#f9e2af',
          gui = 'bold',
        },
        b = {
          fg = '#cdd6f4',
          bg = '#45475a',
        },
        c = {
          fg = '#bac2de',
          bg = '#313244',
        },
      },
      replace = {
        a = {
          fg = '#1e1e2e',
          bg = '#f38ba8',
          gui = 'bold',
        },
        b = {
          fg = '#cdd6f4',
          bg = '#45475a',
        },
        c = {
          fg = '#bac2de',
          bg = '#313244',
        },
      },
      command = {
        a = {
          fg = '#1e1e2e',
          bg = '#cba6f7',
          gui = 'bold',
        },
        b = {
          fg = '#cdd6f4',
          bg = '#45475a',
        },
        c = {
          fg = '#bac2de',
          bg = '#313244',
        },
      },
      inactive = {
        a = {
          fg = '#6c7086',
          bg = '#45475a',
        },
        b = {
          fg = '#6c7086',
          bg = '#45475a',
        },
        c = {
          fg = '#6c7086',
          bg = '#313244',
        },
      },
    }

    lualine.setup({
      options = {
        theme = custom_theme,
        component_separators = {
          left = '',
          right = '',
        },
        section_separators = {
          left = '',
          right = '',
        },
        globalstatus = true,
        always_divide_middle = true,
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        refresh = {
          statusline = 250,
          tabline = 250,
          winbar = 250,
        },
      },
      sections = {
        lualine_a = {
          {
            'mode',
            fmt = function(str) return str:sub(1, 1) end,
          },
        },
        lualine_b = {
          buffer_count,
          {
            notification_error_count,
            color = {
              fg = '#f38ba8',
            },
          },
          {
            notification_warn_count,
            color = {
              fg = '#f9e2af',
            },
          },
          {
            'branch',
            icon = '',
          },
          {
            'diff',
            symbols = {
              added = ' ',
              modified = ' ',
              removed = ' ',
            },
          },
        },
        lualine_c = {
          {
            get_project_name,
            color = {
              fg = '#89b4fa',
              gui = 'bold',
            },
          },
          {
            'filename',
            path = 1,
            symbols = {
              modified = ' ●',
              readonly = ' ',
              unnamed = '[No Name]',
            },
            fmt = function(str)
              -- Get current buffer info
              local bufnr = vim.api.nvim_get_current_buf()
              local buf_name = vim.api.nvim_buf_get_name(bufnr)
              local buf_type = vim.bo[bufnr].buftype
              local filetype = vim.bo[bufnr].filetype

              -- Priority 1.5: Handle trouble buffers - use filetype as primary detection
              if filetype == 'trouble' then
                -- This is definitely a trouble buffer, let's determine what type

                -- First check if we have a stored mode globally
                if _G.current_trouble_mode then
                  local mode_map = {
                    diagnostics = ' Workspace Problems',
                    quickfix = ' Quickfix',
                    loclist = ' Location List',
                    lsp_references = ' References',
                    lsp_definitions = ' Definitions',
                    lsp_type_definitions = ' Type Defs',
                    lsp_implementations = ' Implementations',
                    lsp_document_symbols = ' Symbols',
                    lsp_workspace_symbols = ' Workspace',
                  }

                  return mode_map[_G.current_trouble_mode]
                    or (' ' .. (_G.current_trouble_mode:gsub('_', ' '):gsub('^%l', string.upper)))
                end

                -- Fallback: try to detect via trouble view
                local view_ok, view = pcall(require, 'trouble.view')
                if view_ok and view.current and view.current.mode then
                  local current_mode = view.current.mode

                  -- Map trouble modes to display names
                  local mode_map = {
                    diagnostics = ' Workspace Problems',
                    quickfix = ' Quickfix',
                    loclist = ' Location List',
                    lsp_references = ' References',
                    lsp_definitions = ' Definitions',
                    lsp_type_definitions = ' Type Defs',
                    lsp_implementations = ' Implementations',
                    lsp_document_symbols = ' Symbols',
                    lsp_workspace_symbols = ' Workspace',
                  }

                  return mode_map[current_mode] or ' Trouble'
                end

                return ' Trouble'
              end

              -- Priority 2: Handle trouble buffers with buffer name patterns (fallback)
              if buf_name:match('^trouble://') or buf_name:find('trouble') then
                local trouble_type = buf_name:match('^trouble://([^/]+)')
                if trouble_type then
                  local type_map = {
                    diagnostics = ' Workspace Problems',
                    quickfix = ' Quickfix',
                    loclist = ' Location List',
                    lsp_references = ' References',
                    lsp_definitions = ' Definitions',
                    lsp_type_definitions = ' Type Defs',
                    lsp_implementations = ' Implementations',
                    lsp_document_symbols = ' Symbols',
                    lsp_workspace_symbols = ' Workspace',
                  }
                  return type_map[trouble_type] or (' ' .. trouble_type:gsub('_', ' '):gsub('^%l', string.upper))
                end
                return ' Trouble'
              end

              -- Priority 3: Check for other custom buffer variables
              local custom_name = vim.b[bufnr].custom_buffer_name
              if custom_name and custom_name ~= '' then return custom_name end

              -- Priority 4: Handle special buffer types
              if buf_type == 'nofile' or buf_type == 'terminal' then
                -- Handle terminal buffers
                if buf_name:match('^term://') then return '  Terminal' end

                -- Handle other special buffers based on filetype
                local filetype_names = {
                  notify = ' Notifications',
                  noice = ' Messages',
                  outputpanel = ' Output',
                }

                if filetype_names[filetype] then return filetype_names[filetype] end

                -- Handle other special buffers based on buffer name patterns
                local special_names = {
                  ['NvimTree'] = ' Files',
                  ['neo-tree'] = ' Files',
                  ['aerial'] = ' Outline',
                  ['Outline'] = ' Outline',
                  ['dapui_'] = ' Debug',
                  ['dap-repl'] = ' Debug REPL',
                  ['gitcommit'] = ' Git Commit',
                  ['fugitive://'] = ' Git',
                  ['DiffviewFiles'] = ' Git Diff',
                  ['NeogitStatus'] = ' Git Status',
                }

                for pattern, name in pairs(special_names) do
                  if buf_name:find(pattern) then return name end
                end

                -- Special handling for empty buffer names with nofile type
                if buf_name == '' and buf_type == 'nofile' then return '[Special Buffer]' end

                -- If it's a nofile buffer but no special handling, show buffer type
                if buf_type == 'nofile' then return '[' .. (buf_type:gsub('^%l', string.upper)) .. ']' end
              end

              -- Priority 5: Return original string for normal files
              return str
            end,
          },
        },
        lualine_x = {
          {
            get_tag_status,
            color = function()
              local status = get_tag_status()
              if status:match('Updating') then
                return {
                  fg = '#f9e2af',
                }
              else
                return {
                  fg = '#a6e3a1',
                }
              end
            end,
          },
          {
            java_version,
            color = {
              fg = '#fab387',
            },
          },
          {
            get_lsp_status,
            color = {
              fg = '#89b4fa',
            },
          },
          {
            'diagnostics',
            sources = { 'nvim_diagnostic' },
            symbols = {
              error = ' ',
              warn = ' ',
              info = ' ',
              hint = ' ',
            },
          },
        },
        lualine_y = {
          {
            'encoding',
            fmt = function(str) return str:upper() end,
          },
          {
            function()
              local format = vim.bo.fileformat
              if format == 'unix' then
                return ' '
              elseif format == 'dos' then
                return ' '
              elseif format == 'mac' then
                return ' '
              else
                return format
              end
            end,
            color = {
              fg = '#89b4fa',
              gui = 'bold',
            },
          },
          'filetype',
        },
        lualine_z = { 'progress', 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { {
          'filename',
          path = 1,
        } },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = { 'nvim-tree', 'quickfix', 'fugitive' },
    })

    -- Auto-refresh when LSP attaches/detaches
    local lsp_group = vim.api.nvim_create_augroup('StatuslineLSP', {
      clear = true,
    })
    vim.api.nvim_create_autocmd('LspAttach', {
      group = lsp_group,
      callback = function() vim.cmd('redrawstatus') end,
    })
    vim.api.nvim_create_autocmd('LspDetach', {
      group = lsp_group,
      callback = function() vim.cmd('redrawstatus') end,
    })

    -- Auto-refresh when buffer changes to ensure statusline is always visible
    local buffer_group = vim.api.nvim_create_augroup('StatuslineBuffer', {
      clear = true,
    })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'WinNew' }, {
      group = buffer_group,
      callback = function() vim.cmd('redrawstatus') end,
    })

    -- Ensure statusline is redrawn on colorscheme change
    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = function()
        vim.defer_fn(function() vim.cmd('redrawstatus') end, 100)
      end,
    })
  end,
}
