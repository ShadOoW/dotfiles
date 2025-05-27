-- Vim options
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader =
	" "
vim.g.maplocalleader =
	" "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font =
	true

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number =
	true
-- You can also add relative line numbers, to help with jumping.
vim.opt.relativenumber =
	true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse =
	"a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode =
	false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(
	function()
		vim.opt.clipboard =
			"unnamedplus"
	end
)

-- Enable break indent
vim.opt.breakindent =
	true

-- Save undo history
vim.opt.undofile =
	true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase =
	true
vim.opt.smartcase =
	true

-- Keep signcolumn on by default
vim.opt.signcolumn =
	"yes"

-- Decrease update time
vim.opt.updatetime =
	250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen =
	300

-- Configure how new splits should be opened
vim.opt.splitright =
	true
vim.opt.splitbelow =
	true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.opt.list =
	true
vim.opt.listchars =
	{
		tab = "» ",
		trail = "·",
		nbsp = "␣",
	}

-- Preview substitutions live, as you type!
vim.opt.inccommand =
	"split"

-- Show which line your cursor is on
vim.opt.cursorline =
	true
vim.opt.cursorlineopt =
	"number,line"
vim.opt.cursorcolumn =
	true -- highlight the current column

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff =
	10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.opt.confirm =
	true

-- Don't wrap lines
vim.opt.wrap =
	false

-- Tab settings
vim.opt.tabstop =
	2
vim.opt.shiftwidth =
	2
vim.opt.expandtab =
	true

-- Enable true color support
vim.opt.termguicolors =
	true

-- Session options
vim.opt.sessionoptions =
	"blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Customize cursor appearance
vim.api.nvim_set_hl(
	0,
	"Cursor",
	{
		blend = 50,
	}
) -- Make cursor 50% transparent
vim.api.nvim_set_hl(
	0,
	"lCursor",
	{
		blend = 50,
	}
) -- Make lCursor 50% transparent
vim.api.nvim_set_hl(
	0,
	"CursorLine",
	{
		blend = 20,
	}
) -- Make cursor line slightly transparent
vim.api.nvim_set_hl(
	0,
	"CursorColumn",
	{
		blend = 20,
	}
) -- Make cursor column slightly transparent

vim.opt.guicursor =
	{
		"n-v:ver25-Cursor/lCursor", -- vertical bar in normal and visual mode (non-blinking)
		"i-ci:ver25-blinkwait700-blinkoff400-blinkon250-Cursor/lCursor", -- vertical bar in insert and insert-command (blinking)
		"r-cr:hor20", -- horizontal bar in replace modes
		"o:hor50", -- horizontal bar in operator-pending
		"sm:block-blinkwait175-blinkoff150-blinkon175", -- showmatch cursor
	}

-- Additional mode indicators
vim.api.nvim_set_hl(
	0,
	"ModeMsg",
	{
		fg = "#89b4fa",
		bold = true,
	}
) -- Customize mode message color
vim.opt.showmode =
	true -- Show current mode in status line
vim.opt.statusline =
	"%{mode()}" -- Show mode in status line

-- Use latest version of file.
vim.opt.autoread =
	true
vim.api.nvim_create_autocmd(
	{
		"FocusGained",
		"BufEnter",
		"CursorHold",
	},
	{
		command = "checktime",
	}
)
vim.opt.swapfile =
	true
vim.opt.backup =
	true
vim.opt.writebackup =
	true
vim.opt.backupcopy =
	"auto"
vim.opt.directory =
	"/tmp/nvim/swap//"
vim.opt.backupdir =
	"/tmp/nvim/backup//"
vim.opt.undodir =
	"/tmp/nvim/undo//"
