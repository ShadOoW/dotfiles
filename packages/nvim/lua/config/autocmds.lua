-- Autocommands
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', {
    clear = true,
  }),
  callback = function() vim.highlight.on_yank() end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

-- Enhanced file auto-reload for tmux/multi-instance scenarios
local file_reload_group = vim.api.nvim_create_augroup('file-auto-reload', {
  clear = true,
})

-- Check for file changes when gaining focus or entering buffers
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  group = file_reload_group,
  desc = 'Check for file changes and reload if buffer is unchanged',
  callback = function(event)
    local buf = event.buf

    -- Skip if buffer is not a file or is modified
    if vim.bo[buf].buftype ~= '' or vim.bo[buf].modified then return end

    -- Skip if file doesn't exist
    local file_path = vim.api.nvim_buf_get_name(buf)
    if file_path == '' or vim.fn.filereadable(file_path) == 0 then return end

    -- Check if file has been modified externally
    vim.cmd('checktime')
  end,
})

-- Auto-reload files when they change externally (only if buffer is unmodified)
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  group = file_reload_group,
  desc = 'Notify when file is reloaded due to external changes',
  callback = function()
    local file_name = vim.fn.expand('<afile>')
    vim.notify('File reloaded: ' .. vim.fn.fnamemodify(file_name, ':~'), vim.log.levels.INFO, {
      title = 'File Auto-Reload',
      timeout = 2000,
    })
  end,
})

-- Handle tmux focus events properly
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  group = file_reload_group,
  desc = 'Handle tmux focus detection',
  callback = function()
    -- Force a redraw to ensure proper focus detection in tmux
    vim.cmd('redraw!')
  end,
})

-- Terminal focus handling for better tmux integration
vim.api.nvim_create_autocmd('TermEnter', {
  group = file_reload_group,
  desc = 'Handle terminal enter events in tmux',
  callback = function()
    -- Check for file changes when entering terminal mode
    vim.schedule(function() vim.cmd('checktime') end)
  end,
})

-- Disable document highlight for file types that often cause issues
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'text', 'txt', 'help', 'log', 'json', 'yaml', 'toml', 'conf' },
  callback = function(args)
    -- Clear any existing document highlight autocommands for this buffer
    vim.api.nvim_clear_autocmds({
      group = 'lsp-document-highlight-' .. args.buf,
      buffer = args.buf,
    })
  end,
  desc = 'Disable document highlight for specific file types',
})

-- Auto-indent and split tags on <CR> in HTML-like files
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'html', 'xml', 'typescriptreact', 'javascriptreact', 'tsx', 'jsx', 'astro' },
  callback = function()
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
    })
  end,
})

-- Enhanced session management for tmux workflows
local session_group = vim.api.nvim_create_augroup('session-management', {
  clear = true,
})

-- Auto-save session on exit for project-based workflows
vim.api.nvim_create_autocmd('VimLeavePre', {
  group = session_group,
  desc = 'Auto-save session before leaving',
  callback = function()
    local cwd = vim.fn.getcwd()
    local session_name = vim.fn.fnamemodify(cwd, ':t')

    -- Only save session if we're in a project directory (has .git or similar)
    if
      vim.fn.isdirectory('.git') == 1
      or vim.fn.filereadable('package.json') == 1
      or vim.fn.filereadable('Cargo.toml') == 1
      or vim.fn.filereadable('go.mod') == 1
      or vim.fn.filereadable('gradle.properties') == 1
      or vim.fn.filereadable('pom.xml') == 1
    then
      require('mini.sessions').write(session_name, {
        force = true,
      })
    end
  end,
})

-- Window management for better tmux integration
local window_group = vim.api.nvim_create_augroup('window-management', {
  clear = true,
})

-- Automatically equalize splits when terminal is resized
vim.api.nvim_create_autocmd('VimResized', {
  group = window_group,
  desc = 'Automatically equalize splits when terminal is resized',
  callback = function() vim.cmd('wincmd =') end,
})

-- Focus events for better tmux pane switching
vim.api.nvim_create_autocmd('WinEnter', {
  group = window_group,
  desc = 'Handle window focus events',
  callback = function()
    -- Update window-local options when entering a window
    vim.wo.cursorline = true
  end,
})

vim.api.nvim_create_autocmd('WinLeave', {
  group = window_group,
  desc = 'Handle window leave events',
  callback = function()
    -- Dim cursor line when leaving a window
    vim.wo.cursorline = false
  end,
})

-- Buffer management for split preservation
local buffer_group = vim.api.nvim_create_augroup('buffer-management', {
  clear = true,
})

-- Prevent closing splits when deleting the last buffer
vim.api.nvim_create_autocmd('BufDelete', {
  group = buffer_group,
  desc = 'Prevent split closure when deleting last buffer',
  callback = function(args)
    local buf = args.buf
    local win = vim.api.nvim_get_current_win()

    -- Skip if this isn't a normal buffer
    if vim.bo[buf].buftype ~= '' then return end

    -- Check if this is the only buffer in the window
    local buffers_in_win = vim.tbl_filter(
      function(b)
        return vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buftype == '' and vim.api.nvim_buf_get_name(b) ~= ''
      end,
      vim.api.nvim_list_bufs()
    )

    -- If there's only one buffer and multiple windows, create a new empty buffer
    if #buffers_in_win <= 1 and #vim.api.nvim_list_wins() > 1 then
      vim.schedule(function()
        -- Create a new empty buffer
        local new_buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_win_set_buf(win, new_buf)
        -- Make the buffer read-only and non-modifiable
        vim.bo[new_buf].readonly = true
        vim.bo[new_buf].modifiable = false
        vim.bo[new_buf].buftype = 'nofile'
      end)
    end
  end,
})

-- Note: Bd and Q commands are now defined in commands.lua
