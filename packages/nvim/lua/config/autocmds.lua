-- Autocommands
local notify = require('utils.notify')

-- Create an augroup for panel management
local panel_group = vim.api.nvim_create_augroup('panel-management', {
    clear = true
})

-- Generic panel closing with 'q' for non-file buffers
vim.api.nvim_create_autocmd('FileType', {
    group = panel_group,
    pattern = '*',
    callback = function()
        -- List of filetypes that should be treated as panels/windows
        local panel_filetypes = {'qf', -- Quickfix
        'help', -- Help files
        'fugitive', -- Git windows
        'git', -- Git windows
        'neotest-summary', -- Test summary
        'neotest-output', -- Test output
        'tsplayground', -- Treesitter playground
        'lspinfo', -- LSP info
        'spectre_panel', -- Search/replace
        'startuptime', -- Startup time
        'aerial', -- Symbol outline
        'neotest-output-panel', -- Test output panel
        'checkhealth', -- Health check
        'man', -- Man pages
        'diagnostics', -- Diagnostic windows
        'DiffviewFiles', -- Diffview files
        'DiffviewFileHistory', -- Diffview history
        'Outline', -- Symbol outline
        'TelescopePrompt', -- Telescope
        'Trouble', -- Diagnostics
        'sagaoutline' -- LSP Saga outline
        }

        -- Check if current buffer should be treated as a panel
        local is_panel = vim.tbl_contains(panel_filetypes, vim.bo.filetype) or
                             (vim.bo.buftype ~= '' and vim.bo.buftype ~= 'terminal')

        if is_panel then
            -- Set buffer-local mapping for 'q' to close the window
            vim.keymap.set('n', 'q', '<cmd>close<CR>', {
                buffer = true,
                silent = true,
                desc = 'Close panel with q'
            })
        end
    end,
    desc = 'Set up panel closing behavior'
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('highlight-yank', {
        clear = true
    }),
    callback = function()
        vim.highlight.on_yank()
    end
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd('BufReadPost', {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end
})

-- Enhanced file auto-reload for tmux/multi-instance scenarios
local file_reload_group = vim.api.nvim_create_augroup('file-auto-reload', {
    clear = true
})

-- Check for file changes when gaining focus or entering buffers
vim.api.nvim_create_autocmd({'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI'}, {
    group = file_reload_group,
    desc = 'Check for file changes and reload if buffer is unchanged',
    callback = function(event)
        local buf = event.buf

        -- Skip if buffer is not a file or is modified
        if vim.bo[buf].buftype ~= '' or vim.bo[buf].modified then
            return
        end

        -- Skip if file doesn't exist
        local file_path = vim.api.nvim_buf_get_name(buf)
        if file_path == '' or vim.fn.filereadable(file_path) == 0 then
            return
        end

        -- Check if file has been modified externally
        vim.cmd('checktime')
    end
})

-- Auto-reload files when they change externally (only if buffer is unmodified)
vim.api.nvim_create_autocmd('FileChangedShellPost', {
    group = file_reload_group,
    desc = 'Notify when file is reloaded due to external changes',
    callback = function()
        local file_name = vim.fn.expand('<afile>')
        notify.info('File Auto-Reload', 'File reloaded: ' .. vim.fn.fnamemodify(file_name, ':~'))
    end
})

-- Handle tmux focus events properly
vim.api.nvim_create_autocmd({'FocusGained', 'BufEnter'}, {
    group = file_reload_group,
    desc = 'Handle tmux focus detection',
    callback = function()
        -- Force a redraw to ensure proper focus detection in tmux
        vim.cmd('redraw!')
    end
})

-- Terminal focus handling for better tmux integration
vim.api.nvim_create_autocmd('TermEnter', {
    group = file_reload_group,
    desc = 'Handle terminal enter events in tmux',
    callback = function()
        -- Check for file changes when entering terminal mode
        vim.schedule(function()
            vim.cmd('checktime')
        end)
    end
})

-- Disable document highlight for file types that often cause issues
vim.api.nvim_create_autocmd('FileType', {
    pattern = {'markdown', 'text', 'txt', 'help', 'log', 'json', 'yaml', 'toml', 'conf'},
    callback = function(args)
        -- Clear any existing document highlight autocommands for this buffer
        -- Use pcall to safely clear autocmds that might not exist
        pcall(vim.api.nvim_clear_autocmds, {
            group = 'lsp-document-highlight-' .. args.buf,
            buffer = args.buf
        })
    end,
    desc = 'Disable document highlight for specific file types'
})

-- Enhanced auto-indent and split tags on <CR> in web framework files (excluding pure HTML)
vim.api.nvim_create_autocmd('FileType', {
    pattern = {'xml', 'typescriptreact', 'javascriptreact', 'tsx', 'jsx', 'astro', 'vue', 'svelte'},
    callback = function()
        -- Auto-split tags for frameworks (HTML handled separately for superhtml compatibility)
        vim.keymap.set('i', '<CR>', function()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            local line = vim.api.nvim_get_current_line()
            if col > 0 and line:sub(col, col) == '>' and line:sub(col + 1, col + 1) == '<' then
                return '<CR><CR><Up><C-f>'
            else
                return '<CR>'
            end
        end, {
            expr = true,
            buffer = true,
            desc = 'Auto-split tags in web frameworks'
        })

        -- Enable embedded language highlighting
        vim.bo.suffixesadd = '.js,.ts,.css,.scss,.less'

        -- Set specific options for better web development
        vim.bo.shiftwidth = 2
        vim.bo.tabstop = 2
        vim.bo.softtabstop = 2
        vim.bo.expandtab = true
    end,
    desc = 'Configure web framework files (excluding HTML for superhtml compatibility)'
})

-- Enhanced HTML/CSS/JS error checking
vim.api.nvim_create_autocmd('FileType', {
    pattern = {'html', 'css', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact'},
    callback = function()
        -- Enable more aggressive diagnostics for web files with error handling
        local buf = vim.api.nvim_get_current_buf()

        -- Only configure diagnostics if buffer is valid
        if vim.api.nvim_buf_is_valid(buf) then
            local ok, _ = pcall(vim.diagnostic.config, {
                -- VS Code-like: show inline text for warnings and errors and include source when useful
                virtual_text = {
                    source = 'if_many'
                },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true
            }, buf)

            -- If diagnostic config fails, just silently continue
            if not ok then
                notify.debug('Failed to configure diagnostics for buffer ' .. buf)
            end
        end
    end
})

-- Window management for better tmux integration
local window_group = vim.api.nvim_create_augroup('window-management', {
    clear = true
})

-- Automatically equalize splits when terminal is resized
vim.api.nvim_create_autocmd('VimResized', {
    group = window_group,
    desc = 'Automatically equalize splits when terminal is resized',
    callback = function()
        vim.cmd('wincmd =')
    end
})

-- Focus events and empty winbar (top gap) for normal buffers
vim.api.nvim_create_autocmd({'WinEnter', 'BufEnter'}, {
    group = window_group,
    desc = 'Handle window focus and empty winbar for top gap',
    callback = function()
        vim.wo.cursorline = true
        -- Empty winbar = true top gap below tabline; clear it for special buffers
        local buftype = vim.bo.buftype
        local ft = vim.bo.filetype
        local skip_winbar =
            buftype == 'terminal' or buftype == 'help' or ft == 'qf' or ft == 'Trouble' or ft == 'lazy' or ft == 'mason'
        -- For normal buffers, draw the separator line on the winbar row using TabbyTopGap
        vim.wo.winbar = (skip_winbar and '' or '%#TabbyTopGap# ')
    end
})

vim.api.nvim_create_autocmd('WinLeave', {
    group = window_group,
    desc = 'Handle window leave events',
    callback = function()
        -- Dim cursor line when leaving a window
        vim.wo.cursorline = false
    end
})

-- Auto-trim trailing whitespace on save (for mini.trailspace)
local trailspace_group = vim.api.nvim_create_augroup('trailspace-management', {
    clear = true
})

vim.api.nvim_create_autocmd('BufWritePre', {
    group = trailspace_group,
    pattern = '*',
    callback = function()
        -- Skip certain filetypes where trailing whitespace might be meaningful
        local skip_filetypes = {'markdown', 'text', 'diff', 'gitcommit'}

        if not vim.tbl_contains(skip_filetypes, vim.bo.filetype) then
            require('mini.trailspace').trim()
        end
    end,
    desc = 'Trim trailing whitespace on save'
})

-- Enhanced HTML5 compliance for superhtml
vim.api.nvim_create_autocmd('FileType', {
    group = trailspace_group,
    pattern = {'html', 'htm', 'xhtml'},
    callback = function()
        -- Ensure HTML files follow HTML5 standards for superhtml
        vim.bo.shiftwidth = 2
        vim.bo.tabstop = 2
        vim.bo.softtabstop = 2
        vim.bo.expandtab = true

        -- Set buffer options for HTML5 compliance
        vim.bo.textwidth = 120 -- Match superhtml wrapLineLength

        -- Enhanced keymap for HTML5 void elements (self-closing tags that shouldn't close)
        vim.keymap.set('i', '<CR>', function()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            local line = vim.api.nvim_get_current_line()
            local before_cursor = line:sub(1, col)
            local after_cursor = line:sub(col + 1)

            -- Check for HTML5 void elements that should NOT be self-closing
            local void_elements = {'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'source',
                                   'track', 'wbr'}

            -- Enhanced tag splitting for proper HTML5 formatting
            if col > 0 and before_cursor:match('<%w+[^>]*>$') and after_cursor:match('^</%w+>') then
                -- Split between opening and closing tags
                return '<CR><CR><Up><C-f>'
            elseif before_cursor:match('<(' .. table.concat(void_elements, '|') .. ')[^>]*/>$') then
                -- Convert self-closing void elements to proper HTML5 format
                local element = before_cursor:match('<(%w+)')
                if element and vim.tbl_contains(void_elements, element) then
                    -- Remove the slash from void elements (HTML5 standard)
                    local new_line = before_cursor:gsub('/>$', '>')
                    vim.api.nvim_set_current_line(new_line .. after_cursor)
                    vim.api.nvim_win_set_cursor(0, {row, #new_line})
                end
                return '<CR>'
            else
                return '<CR>'
            end
        end, {
            expr = true,
            buffer = true,
            desc = 'Enhanced HTML5-compliant tag splitting'
        })
    end,
    desc = 'Configure HTML files for superhtml and HTML5 compliance'
})

-- Mini.files enhanced keybindings
local minifiles_group = vim.api.nvim_create_augroup('minifiles-enhanced', {
    clear = true
})

vim.api.nvim_create_autocmd('User', {
    group = minifiles_group,
    pattern = 'MiniFilesBufferCreate',
    callback = function(args)
        local buf_id = args.data.buf_id

        -- Add custom keybindings for this buffer
        vim.keymap.set('n', '<C-s>', function()
            require('mini.files').synchronize()
        end, {
            buffer = buf_id,
            desc = 'Synchronize changes (save/create files)'
        })
    end,
    desc = 'Set up mini.files buffer keybindings'
})

-- Ensure files always end with a newline when saving
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*',
    callback = function()
        -- Ensure the file ends with a newline
        local buf = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        if #lines > 0 and lines[#lines] ~= '' then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, {''})
        end
    end
})

-- Enhanced session post-load handling: Clean up unwanted windows and conditionally open Lazy/Mason
vim.api.nvim_create_autocmd('User', {
    pattern = 'PersistenceLoadPost',
    callback = function()
        -- First, close any problematic windows that might have been restored
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local filetype = vim.bo[buf].filetype or ''
            local buftype = vim.bo[buf].buftype or ''

            -- Close floating windows and specific problematic buffers
            local config = vim.api.nvim_win_get_config(win)
            if config.relative ~= '' or filetype == 'trouble' or filetype == 'noice' or filetype == 'lazy' or filetype ==
                'mason' then
                pcall(vim.api.nvim_win_close, win, true)
            end
        end

        -- Check if we need to open Lazy or Mason conditionally
        vim.schedule(function()
            local session_utils = require('utils.session')
            local action = session_utils.get_post_session_action()

            if action == 'lazy' then
                vim.defer_fn(function()
                    vim.cmd('Lazy')
                    notify.info('Session Restore', 'Lazy opened - pending plugin operations detected')
                end, 150)
            elseif action == 'mason' then
                vim.defer_fn(function()
                    vim.cmd('Mason')
                    notify.info('Session Restore', 'Mason opened - pending tool installations detected')
                end, 150)
            end
        end)
    end,
    desc = 'Clean up problematic windows and conditionally open Lazy/Mason after session restore'
})

-- Handle all vim errors as notifications instead of center screen
vim.api.nvim_create_autocmd('CmdlineLeave', {
    group = vim.api.nvim_create_augroup('error-notifications', {
        clear = true
    }),
    callback = function()
        local msg = vim.v.errmsg
        if msg and msg ~= '' then
            -- Filter out known harmless errors that don't need notification
            local ignored_errors =
                {'E119: Not enough arguments for function: matchdelete', -- vim-matchup internal error
                'E803: ID not found:' -- Match ID not found (harmless)
                }

            local should_ignore = false
            for _, pattern in ipairs(ignored_errors) do
                if msg:match(pattern) then
                    should_ignore = true
                    break
                end
            end

            if not should_ignore then
                -- Convert error messages to notifications
                require('utils.notify').error('Vim Error', msg)
            end

            vim.v.errmsg = '' -- Clear the error message to prevent center screen display
        end
    end
})
