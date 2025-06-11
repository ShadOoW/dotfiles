-- Keymaps configuration
local keymap = require("utils.keymap")

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
keymap.n("<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlights")

-- Unified split commands (matching tmux)
keymap.n("<C-M-v>", "<cmd>vsplit<CR>", "Split window vertically (unified)")
keymap.n("<C-M-s>", "<cmd>split<CR>", "Split window horizontally (unified)")

-- Move windows around
keymap.n("<C-S-h>", "<C-w>H", "Move window to the left")
keymap.n("<C-S-l>", "<C-w>L", "Move window to the right")
keymap.n("<C-S-j>", "<C-w>J", "Move window to the bottom")
keymap.n("<C-S-k>", "<C-w>K", "Move window to the top")

-- File operations keymaps
keymap.n("<leader>fq", function()
	require("mini.bufremove").delete(0, false)
end, "Close file (preserve split)")
keymap.n("<leader>fw", "<cmd>write<CR>", "Write file")

-- Buffer navigation with leader+arrow keys
keymap.n("<leader><Right>", "<cmd>bnext<CR>", "Next buffer")
keymap.n("<leader><Left>", "<cmd>bprevious<CR>", "Previous buffer")

-- LSP Goto keymaps
keymap.n("<leader>ga", vim.lsp.buf.code_action, "Code Action")
keymap.n("<leader>gr", function()
	require("telescope.builtin").lsp_references()
end, "List References")
keymap.n("<leader>gi", function()
	require("telescope.builtin").lsp_implementations()
end, "List Implementations")
keymap.n("<leader>gd", function()
	require("telescope.builtin").lsp_definitions()
end, "List Definitions")
keymap.n("<leader>gD", vim.lsp.buf.declaration, "Goto Declaration")
keymap.n("<leader>gt", function()
	require("telescope.builtin").lsp_type_definitions()
end, "List Type Definitions")
keymap.n("<leader>gr", "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename symbol")
keymap.n("<leader>gh", "<cmd>lua vim.lsp.buf.hover()<cr>", "Hover documentation")

-- Indentation in visual mode
keymap.v("<", "<gv", "Outdent line")
keymap.v(">", ">gv", "Indent line")

-- Move lines up and down
keymap.v("J", ":m '>+1<CR>gv=gv", "Move selection down")
keymap.v("K", ":m '<-2<CR>gv=gv", "Move selection up")

-- Search and replace current word
keymap.n("<leader>sr", ":%s/<C-r><C-w>//g<Left><Left>", "Word under cursor")
keymap.n("<leader>ss", function()
	require("telescope.builtin").lsp_document_symbols()
end, "Symbols Document")
keymap.n("<leader>sS", function()
	require("telescope.builtin").lsp_dynamic_workspace_symbols()
end, "Symbols Workspace")
keymap.n("<leader>sm", "<cmd>NoiceTelescope<cr>", "Noice messages")

-- Open mini.files with '\'
keymap.n("\\", function()
	-- Open mini.files and reveal current file location
	local minifiles = require("mini.files")
	local current_file = vim.api.nvim_buf_get_name(0)
	if current_file ~= "" and vim.fn.filereadable(current_file) == 1 then
		minifiles.open(current_file)
		minifiles.reveal_cwd()
	else
		minifiles.open()
	end
end, "Open MiniFiles file explorer")

-- Additional mini.files keybinding for current directory
keymap.n("<leader>fE", function()
	require("mini.files").open()
end, "Open MiniFiles in current directory")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Function Keys - Optimized for Development Workflow
-- ═══════════════════════════════════════════════════════════════════════════════
-- F1-F4: Buffer/Window Navigation (complements tmux F1-F4 for window switching)
keymap.n("<F1>", "<cmd>bfirst<CR>", "First buffer")
keymap.n("<F2>", "<cmd>bprevious<CR>", "Previous buffer")
keymap.n("<F3>", "<cmd>bnext<CR>", "Next buffer")
keymap.n("<F4>", "<cmd>blast<CR>", "Last buffer")

-- F5-F8: File Operations & Quick Actions
keymap.n("<F5>", "<cmd>write<CR>", "Save file")
keymap.n("<F6>", function()
	-- Open mini.files in current file directory
	local minifiles = require("mini.files")
	local current_file = vim.api.nvim_buf_get_name(0)
	if current_file ~= "" and vim.fn.filereadable(current_file) == 1 then
		minifiles.open(current_file)
		minifiles.reveal_cwd()
	else
		minifiles.open()
	end
end, "Open file explorer")
keymap.n("<F7>", "<cmd>Telescope find_files<CR>", "Find files")
keymap.n("<F8>", "<cmd>Telescope live_grep<CR>", "Live grep")

-- F9-F12: Development Tools & Advanced Features
keymap.n("<F9>", "<cmd>Telescope buffers<CR>", "Show buffers")
keymap.n("<F10>", "<cmd>Trouble diagnostics toggle<CR>", "Toggle diagnostics")
keymap.n("<F11>", "<cmd>ToggleTerm<CR>", "Toggle terminal")
keymap.n("<F12>", function()
	-- Smart help: show help for word under cursor or general help
	local word = vim.fn.expand("<cword>")
	if word ~= "" then
		vim.cmd("help " .. word)
	else
		vim.cmd("help")
	end
end, "Context help")

-- Shift+Function Keys for Advanced Operations
keymap.n("<S-F1>", "<cmd>tabnew<CR>", "New tab")
keymap.n("<S-F2>", "<cmd>tabprevious<CR>", "Previous tab")
keymap.n("<S-F3>", "<cmd>tabnext<CR>", "Next tab")
keymap.n("<S-F4>", "<cmd>tabclose<CR>", "Close tab")

keymap.n("<S-F5>", "<cmd>wall<CR>", "Save all files")
keymap.n("<S-F6>", "<cmd>source %<CR>", "Source current file")
keymap.n("<S-F7>", "<cmd>Telescope git_files<CR>", "Git files (also <leader>hf)")
keymap.n("<S-F8>", "<cmd>Telescope grep_string<CR>", "Grep word under cursor")

keymap.n("<S-F9>", "<cmd>Telescope quickfix<CR>", "Quickfix list")
keymap.n("<S-F10>", "<cmd>lua vim.diagnostic.open_float()<CR>", "Show diagnostics")
keymap.n("<S-F11>", "<cmd>split | terminal<CR>", "Split terminal")
keymap.n("<S-F12>", "<cmd>lua vim.lsp.buf.hover()<CR>", "LSP hover")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Tmux Integration
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- Admin Category - <leader>A
-- ═══════════════════════════════════════════════════════════════════════════════
-- Tmux:       Aa=list_panes, Ar=reload_buffers, As=focus_sync
-- Noice:      An=noice_search, Al=last_message, Ah=history, AD=dismiss_all
-- Session:    Ap=project_workflow, Ao=output_panel
-- ═══════════════════════════════════════════════════════════════════════════════

-- Tmux Integration
keymap.n("<leader>Aa", "<cmd>TmuxPanes<cr>", "[A]dmin List nvim p[a]nes in tmux session")

keymap.n("<leader>Ar", function()
	vim.cmd("checktime")
	vim.notify("Checked all buffers for external changes", vim.log.levels.INFO)
end, "[A]dmin [R]eload all buffers from disk")

keymap.n("<leader>As", function()
	-- Force focus sync and file check
	vim.cmd("redraw!")
	vim.cmd("checktime")
	if vim.env.TMUX then
		require("utils.tmux").refresh_client()
	end
end, "[A]dmin Force focus [s]ync and file check")

-- Noice Integration

keymap.n("<leader>Al", function()
	require("noice").cmd("last")
end, "[A]dmin Noice [L]ast message")

keymap.n("<leader>Ah", function()
	require("noice").cmd("history")
end, "[A]dmin Noice [H]istory")

keymap.n("<leader>AD", function()
	require("noice").cmd("dismiss")
end, "[A]dmin Noice [D]ismiss all")

-- Session and Project Management
keymap.n("<leader>Ap", function()
	-- Switch to project root and setup session
	local tmux = require("utils.tmux")
	if tmux.is_tmux() then
		tmux.setup_project_workflow()
	end
end, "[A]dmin Setup [p]roject workflow")

keymap.n("<leader>Ao", "<cmd>OutputPanel<CR>", "[A]dmin Toggle [O]utput Panel")

-- Diagnostic keymaps
keymap.n("<leader>pq", vim.diagnostic.setloclist, "Open diagnostic [Q]uickfix list")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Tab Management
-- ═══════════════════════════════════════════════════════════════════════════════

-- Basic tab operations with <leader>t prefix
keymap.n("<leader>tn", "<cmd>tabnew<cr>", "New tab")
keymap.n("<leader>to", "<cmd>tabnew %<cr>", "Open file in new tab")
keymap.n("<leader>tc", "<cmd>tabclose<cr>", "Close tab")
keymap.n("<leader>t]", "<cmd>tabnext<cr>", "Next tab")
keymap.n("<leader>t[", "<cmd>tabprevious<cr>", "Previous tab")
keymap.n("<leader>tf", "<cmd>tabfirst<cr>", "First tab")
keymap.n("<leader>tl", "<cmd>tablast<cr>", "Last tab")

-- Enhanced tab move with prompt for position
keymap.n("<leader>tm", function()
	local pos = vim.fn.input("Move tab to position (0 for first, $ for last): ")
	if pos ~= "" then
		if pos == "$" then
			vim.cmd("tabmove $")
		else
			vim.cmd("tabmove " .. pos)
		end
	end
end, "Move tab to position")

-- Arrow key navigation for tabs
keymap.n("<leader><Up>", "<cmd>tabnext<cr>", "Next tab")
keymap.n("<leader><Down>", "<cmd>tabprevious<cr>", "Previous tab")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Plugin Specific Keymaps (Consolidated from other files)
-- ═══════════════════════════════════════════════════════════════════════════════

-- File operations (from genghis.lua)
keymap.n("<leader>Fp", "<cmd>Genghis copyFilepath<CR>", "Copy file path")
keymap.n("<leader>Fy", "<cmd>Genghis copyFilename<CR>", "Copy filename")
keymap.n("<leader>Fd", "<cmd>Genghis duplicateFile<CR>", "Duplicate file")
keymap.n("<leader>Fr", "<cmd>Genghis renameFile<CR>", "Rename file")
keymap.n("<leader>Fx", "<cmd>Genghis chmodx<CR>", "Make file executable")
keymap.v("<leader>Ff", ":'<,'>Genghis newFileFromSelection<CR>", "New file from selection")
keymap.n("<leader>Fm", "<cmd>Genghis moveFile<CR>", "Move file")
keymap.n("<leader>Ft", "<cmd>Genghis trashFile<CR>", "Trash file")
keymap.v("<leader>FR", ":'<,'>Genghis renameFileToSelection<CR>", "Rename file to selection")

-- Trouble diagnostics (using modern Trouble v3 commands)
keymap.n("<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Toggle trouble diagnostics")
keymap.n("<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", "Workspace diagnostics")
keymap.n("<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Document diagnostics")
keymap.n("<leader>xl", "<cmd>Trouble loclist toggle<cr>", "Location list")
keymap.n("<leader>xq", "<cmd>Trouble qflist toggle<cr>", "Quickfix list")
keymap.n("<leader>xr", "<cmd>Trouble lsp toggle<cr>", "LSP references")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Git Category - <leader>h (Hunks & Git operations)
-- ═══════════════════════════════════════════════════════════════════════════════
-- Hunks:      hj=next_hunk, hk=prev_hunk, hp=preview_hunk
-- Staging:    hs=stage_hunk, hS=stage_buffer, hr=reset_hunk, hR=reset_buffer, hu=undo_stage
-- View:       hb=blame_line, hd=diff_this, hD=diff_this~, htb=toggle_blame, htd=toggle_deleted
-- Files:      hf=git_files, hc=git_commits, hB=git_branches, hst=git_status
-- ═══════════════════════════════════════════════════════════════════════════════

-- Hunk Navigation
keymap.n(
	"<leader>hj",
	function()
		if vim.wo.diff then
			return "]c"
		end
		vim.schedule(function()
			require("gitsigns").next_hunk()
		end)
		return "<Ignore>"
	end,
	"[H]unk Next ([j] down)",
	{
		expr = true,
	}
)

keymap.n(
	"<leader>hk",
	function()
		if vim.wo.diff then
			return "[c"
		end
		vim.schedule(function()
			require("gitsigns").prev_hunk()
		end)
		return "<Ignore>"
	end,
	"[H]unk Previous ([k] up)",
	{
		expr = true,
	}
)

keymap.n("<leader>hp", function()
	require("gitsigns").preview_hunk()
end, "[H]unk [P]review")

-- Hunk Staging Operations
keymap.n("<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", "[H]unk [S]tage")
keymap.v("<leader>hs", ":Gitsigns stage_hunk<CR>", "[H]unk [S]tage")

keymap.n("<leader>hS", function()
	require("gitsigns").stage_buffer()
end, "[H]unk [S]tage entire buffer")

keymap.n("<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", "[H]unk [R]eset")
keymap.v("<leader>hr", ":Gitsigns reset_hunk<CR>", "[H]unk [R]eset")

keymap.n("<leader>hR", function()
	require("gitsigns").reset_buffer()
end, "[H]unk [R]eset entire buffer")

keymap.n("<leader>hu", function()
	require("gitsigns").undo_stage_hunk()
end, "[H]unk [U]ndo stage")

-- Git View and Blame
keymap.n("<leader>hb", function()
	require("gitsigns").blame_line({
		full = true,
	})
end, "[H]unk [B]lame line")

keymap.n("<leader>htb", function()
	require("gitsigns").toggle_current_line_blame()
end, "[H]unk [T]oggle [B]lame")

keymap.n("<leader>hd", function()
	require("gitsigns").diffthis()
end, "[H]unk [D]iff this")

keymap.n("<leader>hD", function()
	require("gitsigns").diffthis("~")
end, "[H]unk [D]iff this (against index)")

keymap.n("<leader>htd", function()
	require("gitsigns").toggle_deleted()
end, "[H]unk [T]oggle [D]eleted")

-- Git File Operations (from Telescope)
keymap.n("<leader>hf", function()
	require("telescope.builtin").git_files(require("telescope.themes").get_dropdown({
		previewer = false,
	}))
end, "[H]unk Git [F]iles")

keymap.n("<leader>hc", function()
	require("telescope.builtin").git_commits(require("telescope.themes").get_ivy())
end, "[H]unk Git [C]ommits")

keymap.n("<leader>hB", function()
	require("telescope.builtin").git_branches(require("telescope.themes").get_dropdown({
		previewer = false,
	}))
end, "[H]unk Git [B]ranches")

keymap.n("<leader>hst", function()
	require("telescope.builtin").git_status(require("telescope.themes").get_ivy())
end, "[H]unk Git [St]atus")

-- Buffer management (from hbac.lua)
keymap.n("<leader>fW", function()
	require("hbac").close_unpinned()
end, "Close all unpinned buffers")
keymap.n("<leader>fP", function()
	require("hbac").toggle_pin()
end, "Toggle pin buffer")

-- Arena buffer selector (from arena.lua)
keymap.n("<leader><leader>", "<cmd>ArenaToggle<CR>", "Toggle Arena")

-- Yank history (from yanky.lua)
keymap.n("<c-n>", "<Plug>(YankyCycleForward)", "Cycle forward in yank history")
keymap.n("<c-p>", "<Plug>(YankyCycleBackward)", "Cycle backward in yank history")
keymap.n("<leader>fy", "<cmd>Telescope yank_history<CR>", "Yank history")

-- Smart window management (from smart-splits.lua)
keymap.n("<C-Left>", function()
	require("smart-splits").resize_left()
end, "Resize window left")
keymap.n("<C-Right>", function()
	require("smart-splits").resize_right()
end, "Resize window right")
keymap.n("<C-Up>", function()
	require("smart-splits").resize_up()
end, "Resize window up")
keymap.n("<C-Down>", function()
	require("smart-splits").resize_down()
end, "Resize window down")
keymap.n("<leader>wv", "<cmd>vsplit<CR>", "Split window vertically")
keymap.n("<leader>ws", "<cmd>split<CR>", "Split window horizontally")
keymap.n("<leader>wq", "<cmd>close<CR>", "Close window")

-- Buffer swapping
keymap.n("<leader>w<Left>", function()
	local function safe_swap_buf_left()
		if vim.fn.winnr("h") ~= vim.fn.winnr() then
			require("smart-splits").swap_buf_left()
		end
	end
	safe_swap_buf_left()
end, "Swap buffer left")
keymap.n("<leader>w<Down>", function()
	require("smart-splits").swap_buf_down()
end, "Swap buffer down")
keymap.n("<leader>w<Up>", function()
	require("smart-splits").swap_buf_up()
end, "Swap buffer up")
keymap.n("<leader>w<Right>", function()
	local function safe_swap_buf_right()
		if vim.fn.winnr("l") ~= vim.fn.winnr() then
			require("smart-splits").swap_buf_right()
		end
	end
	safe_swap_buf_right()
end, "Swap buffer right")

keymap.n("gk", "<cmd>AerialPrev<CR>", "Previous Symbol")
keymap.n("gj", "<cmd>AerialNext<CR>", "Next Symbol")

-- ═══════════════════════════════════════════════════════════════════════════════
-- Debug Category - <leader>d
-- ═══════════════════════════════════════════════════════════════════════════════
-- Session:    dc=continue/start, dt=terminate, dR=restart
-- Stepping:   di=step_into, do=step_over, du=step_out, db=step_back
-- Breakpoint: dB=toggle, dC=conditional, dL=log_point, dx=clear_all, dX=exception
-- UI/Windows: dw=toggle_ui, dh=hover, dp=preview, df=frames, ds=scopes
-- REPL/Eval:  dr=repl, dl=run_last, de=eval
-- Navigation: dg=run_to_cursor, dj=stack_down, dk=stack_up
-- Utilities:  dq=quit_all, d?=help
-- ═══════════════════════════════════════════════════════════════════════════════

-- Debug session control
keymap.n("<leader>dc", function()
	require("dap").continue()
end, "[D]ebug [C]ontinue/Start")

keymap.n("<leader>dt", function()
	require("dap").terminate()
end, "[D]ebug [T]erminate")

keymap.n("<leader>dR", function()
	require("dap").restart()
end, "[D]ebug [R]estart")

-- Debug stepping
keymap.n("<leader>di", function()
	require("dap").step_into()
end, "[D]ebug Step [I]nto")

keymap.n("<leader>do", function()
	require("dap").step_over()
end, "[D]ebug Step [O]ver")

keymap.n("<leader>du", function()
	require("dap").step_out()
end, "[D]ebug Step O[u]t")

keymap.n("<leader>db", function()
	require("dap").step_back()
end, "[D]ebug Step [B]ack")

-- Breakpoint management
keymap.n("<leader>dB", function()
	require("dap").toggle_breakpoint()
end, "[D]ebug Toggle [B]reakpoint")

keymap.n("<leader>dC", function()
	require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, "[D]ebug [C]onditional Breakpoint")

keymap.n("<leader>dL", function()
	require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, "[D]ebug [L]og Point")

keymap.n("<leader>dx", function()
	require("dap").clear_breakpoints()
end, "[D]ebug Clear Breakpoints (E[x]tinguish)")

-- Debug UI and windows
keymap.n("<leader>dw", function()
	require("dapui").toggle()
end, "[D]ebug Toggle UI [W]indow")

keymap.n("<leader>dh", function()
	require("dap.ui.widgets").hover()
end, "[D]ebug [H]over Variables")

keymap.n("<leader>dp", function()
	require("dap.ui.widgets").preview()
end, "[D]ebug [P]review")

keymap.n("<leader>df", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.frames)
end, "[D]ebug [F]rames")

keymap.n("<leader>ds", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.scopes)
end, "[D]ebug [S]copes")

-- Debug REPL and console
keymap.n("<leader>dr", function()
	require("dap").repl.open()
end, "[D]ebug Open [R]EPL")

keymap.n("<leader>dl", function()
	require("dap").run_last()
end, "[D]ebug Run [L]ast")

-- Debug evaluation
keymap.n("<leader>de", function()
	require("dapui").eval()
end, "[D]ebug [E]val Expression")

keymap.v("<leader>de", function()
	require("dapui").eval()
end, "[D]ebug [E]val Selection")

-- Debug configurations
keymap.n("<leader>dg", function()
	require("dap").run_to_cursor()
end, "[D]ebug Run to Cursor ([G]o to cursor)")

keymap.n("<leader>dj", function()
	require("dap").down()
end, "[D]ebug Stack Down ([j] down)")

keymap.n("<leader>dk", function()
	require("dap").up()
end, "[D]ebug Stack Up ([k] up)")

-- Additional debug utilities
keymap.n("<leader>dX", function()
	require("dap").set_exception_breakpoints()
end, "[D]ebug E[X]ception Breakpoints")

keymap.n("<leader>dq", function()
	require("dap").close()
	require("dapui").close()
end, "[D]ebug [Q]uit/Close All")

keymap.n("<leader>d?", function()
	-- Show debug status and available commands
	local dap = require("dap")
	local session = dap.session()
	if session then
		vim.notify("Debug session active: " .. (session.config.name or "Unknown"), vim.log.levels.INFO)
	else
		vim.notify("No active debug session", vim.log.levels.INFO)
	end

	-- Show quick help
	local help_text = [[
<leader>d Debug Commands:
  dc - Continue/Start    dt - Terminate     dR - Restart
  di - Step Into        do - Step Over     du - Step Out       db - Step Back
  dB - Toggle BP        dC - Conditional   dL - Log Point     dx - Clear All
  dw - Toggle UI        dh - Hover         dp - Preview       df - Frames        ds - Scopes
  dr - REPL            dl - Run Last      de - Eval          dg - Run to Cursor
  dj - Stack Down      dk - Stack Up      dX - Exception BP  dq - Quit All
]]
	vim.notify(help_text, vim.log.levels.INFO)
end, "[D]ebug Help (?)")
