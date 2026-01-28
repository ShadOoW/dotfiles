-- Vim options
local notify = require('utils.notify')

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Fix mouse menu issues in different modes
vim.opt.mousemodel = 'extend' -- Right-click extends selection instead of showing menu

-- Force statusline to be always visible
-- vim.opt.laststatus = 3 -- Global statusline
-- vim.opt.cmdheight = 1 -- Command line height

-- Ensure menus are available in all modes (fixes E335)
vim.cmd([[
  " Disable problematic menu entries that can cause E335
  if has('gui_running') || has('nvim')
    " Create basic menu structure to prevent E335 errors
    silent! unmenu *
    " Only define essential menus to avoid conflicts
    menu 10.10 &File.&Open<Tab>:e :browse confirm e<CR>
    menu 10.20 &File.&Save<Tab>:w :confirm w<CR>
    menu 10.30 &File.&Close<Tab>:q :confirm q<CR>
  endif
]])

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
    vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Add padding/spacing around buffer content on all sides
-- Left padding: Increase number column width and add fold column
vim.opt.numberwidth = 6 -- Increased from default 4 for more left spacing
vim.opt.foldcolumn = '1' -- Add fold column for extra left spacing
-- Left/Right padding: Keep columns visible at edges  
vim.opt.sidescrolloff = 8 -- Columns to keep left/right of cursor (creates horizontal gap)

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Always show tabline, even with single tab
vim.opt.showtabline = 2

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.opt.list = true
vim.opt.listchars = {
    tab = '» ',
    trail = '·',
    nbsp = '␣'
}

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'number,line'
vim.opt.cursorcolumn = true -- highlight the current column

-- Empty winbar: reserve one line below tabline for a true top gap (no content)
vim.opt.winbar = ' '

-- Disable all scrolling animations
vim.opt.lazyredraw = false
vim.opt.jumpoptions = 'stack'

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.opt.confirm = true

-- Don't wrap lines
vim.opt.wrap = false

-- Tab settings
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- File formatting options
vim.opt.fixendofline = true
vim.opt.endofline = true
vim.opt.fileformat = 'unix'

-- Better paste behavior to avoid extra empty lines
vim.keymap.set('v', 'p', function()
    -- Store current register content
    local reg_content = vim.fn.getreg('"')
    local reg_type = vim.fn.getregtype('"')

    -- Delete visual selection and paste
    vim.cmd('normal! "_dP')

    -- If the pasted content doesn't end with a newline and we're at buffer start,
    -- remove any extra empty line that might have been created
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    if cursor_pos[1] == 1 then
        local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
        if first_line == '' then
            local second_line = vim.api.nvim_buf_get_lines(0, 1, 2, false)[1]
            if second_line and second_line ~= '' then
                vim.api.nvim_buf_set_lines(0, 0, 1, false, {})
            end
        end
    end
end, {
    desc = 'Paste in visual mode without extra empty lines'
})

-- Enable true color support
vim.opt.termguicolors = true

-- Prevent unnamed buffer creation on startup
vim.opt.shortmess:append('I') -- Remove intro message
vim.opt.cmdheight = 0 -- Hide command line when not in use

-- Additional options to prevent unwanted buffer creation
vim.opt.hidden = true -- Allow hidden buffers
vim.opt.confirm = false -- Don't confirm when abandoning buffers

-- Disable netrw completely since we're using telescope file browser
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Conceallevel and modifiable settings for markdown files
local markdown_group = vim.api.nvim_create_augroup('MarkdownSettings', {
    clear = true
})

vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile', 'FileType'}, {
    group = markdown_group,
    pattern = {'*.md', 'markdown'},
    callback = function()
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = 'nc'
        vim.opt_local.modifiable = true
        vim.opt_local.wrap = true
    end,
    desc = 'Set conceallevel and modifiable for markdown files'
})

-- Protect conceallevel from being changed by other plugins
vim.api.nvim_create_autocmd({'ModeChanged', 'CmdlineEnter', 'CmdlineLeave'}, {
    group = markdown_group,
    pattern = '*',
    callback = function()
        if vim.bo.filetype == 'markdown' and vim.opt_local.conceallevel:get() ~= 2 then
            vim.opt_local.conceallevel = 2
            vim.opt_local.concealcursor = 'nc'
        end
    end,
    desc = 'Protect conceallevel=2 in markdown files from mode changes'
})

-- Clean startup - remove intro and make buffers behave properly
vim.api.nvim_create_autocmd('VimEnter', {
    group = vim.api.nvim_create_augroup('CleanStartup', {
        clear = true
    }),
    callback = function()
        -- Only clean up if no arguments and buffer is empty
        if vim.fn.argc() == 0 then
            local buf = vim.api.nvim_get_current_buf()
            local bufname = vim.api.nvim_buf_get_name(buf)
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

            -- If buffer is empty and unnamed, that's normal for 'nvim' - leave it be
            -- Session restoration will handle 'nvim .' case
        end
    end
})

-- Session options
vim.opt.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- File type associations
vim.filetype.add({
    extension = {
        odin = 'odin',
        dart = 'dart'
    },
    filename = {
        ['ols.json'] = 'jsonc',
        ['odinfmt.json'] = 'jsonc',
        ['pubspec.yaml'] = 'yaml',
        ['pubspec.yml'] = 'yaml',
        ['analysis_options.yaml'] = 'yaml',
        ['analysis_options.yml'] = 'yaml'
    }
})

-- Odin-specific settings (using personal 2-space convention)
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'odin',
    callback = function()
        -- Use 2 spaces for Odin files (personal preference over community tabs)
        vim.opt_local.expandtab = true
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2

        -- Enable syntax highlighting
        vim.opt_local.syntax = 'on'

        -- Set comment string for Odin
        vim.opt_local.commentstring = '// %s'

        -- Set up proper indentation
        vim.opt_local.smartindent = true
        vim.opt_local.autoindent = true

        -- Enable spell checking in comments
        vim.opt_local.spell = true
        vim.opt_local.spelllang = {'en_us'}
    end
})

-- Dart/Flutter-specific settings
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'dart',
    callback = function()
        -- Use 2 spaces for Dart files (Flutter/Dart convention)
        vim.opt_local.expandtab = true
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2

        -- Enable syntax highlighting
        vim.opt_local.syntax = 'on'

        -- Set comment string for Dart
        vim.opt_local.commentstring = '// %s'

        -- Set up proper indentation
        vim.opt_local.smartindent = true
        vim.opt_local.autoindent = true

        -- Enable spell checking in comments
        vim.opt_local.spell = true
        vim.opt_local.spelllang = {'en_us'}

        -- Text width for Dart (Dart style guide recommends 80)
        vim.opt_local.textwidth = 80

        -- Enable word wrap for long lines
        vim.opt_local.wrap = false

        -- Set up better folding for Flutter widget trees
        vim.opt_local.foldmethod = 'syntax'
        vim.opt_local.foldlevel = 99
    end,
    desc = 'Dart/Flutter file settings'
})

-- Customize cursor appearance
vim.api.nvim_set_hl(0, 'Cursor', {
    blend = 50
}) -- Make cursor 50% transparent
vim.api.nvim_set_hl(0, 'lCursor', {
    blend = 50
}) -- Make lCursor 50% transparent
vim.api.nvim_set_hl(0, 'CursorLine', {
    blend = 20
}) -- Make cursor line slightly transparent
vim.api.nvim_set_hl(0, 'CursorColumn', {
    blend = 20
}) -- Make cursor column slightly transparent

vim.opt.guicursor = {'n-v:ver25-Cursor/lCursor', -- vertical bar in normal and visual mode (non-blinking)
'i-ci:ver25-blinkwait700-blinkoff400-blinkon250-Cursor/lCursor', -- vertical bar in insert and insert-command (blinking)
                     'r-cr:hor20', -- horizontal bar in replace modes
'o:hor50', -- horizontal bar in operator-pending
'sm:block-blinkwait175-blinkoff150-blinkon175' -- showmatch cursor
}

-- Additional mode indicators
vim.api.nvim_set_hl(0, 'ModeMsg', {
    fg = '#89b4fa',
    bold = true
}) -- Customize mode message color
vim.opt.showmode = true -- Show current mode in status line
vim.opt.statusline = '%{mode()}' -- Show mode in status line

-- Use latest version of file with enhanced tmux integration
vim.opt.autoread = true

-- Better swap, backup, and undo file management for multi-instance scenarios
vim.opt.swapfile = true
vim.opt.backup = true
vim.opt.writebackup = true
vim.opt.backupcopy = 'auto'

-- Make swap file warnings more discrete
vim.opt.shortmess:append('A') -- Don't show ATTENTION message for existing swap files
vim.opt.updatecount = 200 -- Write swap file after 200 characters
vim.opt.updatetime = 4000 -- Write swap file after 4 seconds of inactivity

-- Handle swap files gracefully with discrete notifications
vim.api.nvim_create_autocmd('SwapExists', {
    group = vim.api.nvim_create_augroup('DiscreteSwapHandling', {
        clear = true
    }),
    callback = function(args)
        local swap_file = vim.v.swapname
        local file_name = args.file

        -- Show a discrete notification instead of the full dialog
        notify.warn('Swap File',
            string.format('Swap file exists for %s. Press "e" to edit anyway, "r" to recover, "q" to quit.',
                vim.fn.fnamemodify(file_name, ':t')))

        -- Set swap choice to 'e' (edit anyway) by default for non-interactive use
        -- User can still choose 'r' to recover or 'q' to quit when prompted
        vim.v.swapchoice = 'e'
    end,
    desc = 'Handle swap files with discrete notifications'
})

-- Create directories if they don't exist
local data_dir = vim.fn.stdpath('data')
local swap_dir = data_dir .. '/swap'
local backup_dir = data_dir .. '/backup'
local undo_dir = data_dir .. '/undo'

vim.fn.mkdir(swap_dir, 'p')
vim.fn.mkdir(backup_dir, 'p')
vim.fn.mkdir(undo_dir, 'p')

vim.opt.directory = swap_dir .. '//'
vim.opt.backupdir = backup_dir .. '//'
vim.opt.undodir = undo_dir .. '//'

-- Enhanced focus events for tmux
if vim.env.TMUX then
    -- Better focus detection in tmux
    vim.opt.ttimeoutlen = 10
    vim.opt.ttimeout = true

    -- Enable focus events
    vim.api.nvim_command('set eventignore-=FocusGained')
    vim.api.nvim_command('set eventignore-=FocusLost')
end

-- Clipboard configuration
vim.opt.clipboard = 'unnamedplus'

-- Fix clipboard issues on Linux
if vim.fn.has('linux') == 1 then
    if vim.fn.executable('wl-copy') == 1 and vim.fn.executable('wl-paste') == 1 then
        -- Wayland clipboard with better integration
        vim.g.clipboard = {
            name = 'wl-clipboard',
            copy = {
                ['+'] = 'wl-copy --type text/plain',
                ['*'] = 'wl-copy --type text/plain --primary'
            },
            paste = {
                ['+'] = 'wl-paste --no-newline',
                ['*'] = 'wl-paste --no-newline --primary'
            },
            cache_enabled = 0
        }
    elseif vim.fn.executable('xclip') == 1 then
        -- X11 clipboard with xclip
        vim.g.clipboard = {
            name = 'xclip',
            copy = {
                ['+'] = 'xclip -selection clipboard',
                ['*'] = 'xclip -selection primary'
            },
            paste = {
                ['+'] = 'xclip -selection clipboard -o',
                ['*'] = 'xclip -selection primary -o'
            },
            cache_enabled = 0
        }
    elseif vim.fn.executable('xsel') == 1 then
        -- X11 clipboard with xsel
        vim.g.clipboard = {
            name = 'xsel',
            copy = {
                ['+'] = 'xsel --clipboard --input',
                ['*'] = 'xsel --primary --input'
            },
            paste = {
                ['+'] = 'xsel --clipboard --output',
                ['*'] = 'xsel --primary --output'
            },
            cache_enabled = 0
        }
    end
end
