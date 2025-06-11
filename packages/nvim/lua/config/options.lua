-- Vim options
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
vim.opt.mouse = "a"

-- Fix mouse menu issues in different modes
vim.opt.mousemodel = "extend" -- Right-click extends selection instead of showing menu

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
	vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

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
	tab = "» ",
	trail = "·",
	nbsp = "␣",
}

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number,line"
vim.opt.cursorcolumn = true -- highlight the current column

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Disable all scrolling animations
vim.opt.lazyredraw = false
vim.opt.jumpoptions = "stack"

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
vim.opt.fileformat = "unix"

-- Better paste behavior to avoid extra empty lines
vim.keymap.set("v", "p", function()
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
		if first_line == "" then
			local second_line = vim.api.nvim_buf_get_lines(0, 1, 2, false)[1]
			if second_line and second_line ~= "" then
				vim.api.nvim_buf_set_lines(0, 0, 1, false, {})
			end
		end
	end
end, {
	desc = "Paste in visual mode without extra empty lines",
})

-- Enable true color support
vim.opt.termguicolors = true

-- Session options
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Customize cursor appearance
vim.api.nvim_set_hl(0, "Cursor", {
	blend = 50,
}) -- Make cursor 50% transparent
vim.api.nvim_set_hl(0, "lCursor", {
	blend = 50,
}) -- Make lCursor 50% transparent
vim.api.nvim_set_hl(0, "CursorLine", {
	blend = 20,
}) -- Make cursor line slightly transparent
vim.api.nvim_set_hl(0, "CursorColumn", {
	blend = 20,
}) -- Make cursor column slightly transparent

vim.opt.guicursor = {
	"n-v:ver25-Cursor/lCursor", -- vertical bar in normal and visual mode (non-blinking)
	"i-ci:ver25-blinkwait700-blinkoff400-blinkon250-Cursor/lCursor", -- vertical bar in insert and insert-command (blinking)
	"r-cr:hor20", -- horizontal bar in replace modes
	"o:hor50", -- horizontal bar in operator-pending
	"sm:block-blinkwait175-blinkoff150-blinkon175", -- showmatch cursor
}

-- Additional mode indicators
vim.api.nvim_set_hl(0, "ModeMsg", {
	fg = "#89b4fa",
	bold = true,
}) -- Customize mode message color
vim.opt.showmode = true -- Show current mode in status line
vim.opt.statusline = "%{mode()}" -- Show mode in status line

-- Use latest version of file with enhanced tmux integration
vim.opt.autoread = true

-- Better swap, backup, and undo file management for multi-instance scenarios
vim.opt.swapfile = true
vim.opt.backup = true
vim.opt.writebackup = true
vim.opt.backupcopy = "auto"

-- Create directories if they don't exist
local data_dir = vim.fn.stdpath("data")
local swap_dir = data_dir .. "/swap"
local backup_dir = data_dir .. "/backup"
local undo_dir = data_dir .. "/undo"

vim.fn.mkdir(swap_dir, "p")
vim.fn.mkdir(backup_dir, "p")
vim.fn.mkdir(undo_dir, "p")

vim.opt.directory = swap_dir .. "//"
vim.opt.backupdir = backup_dir .. "//"
vim.opt.undodir = undo_dir .. "//"

-- Enhanced focus events for tmux
if vim.env.TMUX then
	-- Better focus detection in tmux
	vim.opt.ttimeoutlen = 10
	vim.opt.ttimeout = true

	-- Enable focus events
	vim.api.nvim_command("set eventignore-=FocusGained")
	vim.api.nvim_command("set eventignore-=FocusLost")
end

-- Clipboard configuration
vim.opt.clipboard = "unnamedplus"

-- Fix clipboard issues on Linux
if vim.fn.has("linux") == 1 then
	if vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1 then
		-- Wayland clipboard with better integration
		vim.g.clipboard = {
			name = "wl-clipboard",
			copy = {
				["+"] = "wl-copy --type text/plain",
				["*"] = "wl-copy --type text/plain --primary",
			},
			paste = {
				["+"] = "wl-paste --no-newline",
				["*"] = "wl-paste --no-newline --primary",
			},
			cache_enabled = 0,
		}
	elseif vim.fn.executable("xclip") == 1 then
		-- X11 clipboard with xclip
		vim.g.clipboard = {
			name = "xclip",
			copy = {
				["+"] = "xclip -selection clipboard",
				["*"] = "xclip -selection primary",
			},
			paste = {
				["+"] = "xclip -selection clipboard -o",
				["*"] = "xclip -selection primary -o",
			},
			cache_enabled = 0,
		}
	elseif vim.fn.executable("xsel") == 1 then
		-- X11 clipboard with xsel
		vim.g.clipboard = {
			name = "xsel",
			copy = {
				["+"] = "xsel --clipboard --input",
				["*"] = "xsel --primary --input",
			},
			paste = {
				["+"] = "xsel --clipboard --output",
				["*"] = "xsel --primary --output",
			},
			cache_enabled = 0,
		}
	end
end
