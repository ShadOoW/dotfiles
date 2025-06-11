-- Autocommands
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", {
		clear = true,
	}),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Enhanced file auto-reload for tmux/multi-instance scenarios
local file_reload_group = vim.api.nvim_create_augroup("file-auto-reload", {
	clear = true,
})

-- Check for file changes when gaining focus or entering buffers
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	group = file_reload_group,
	desc = "Check for file changes and reload if buffer is unchanged",
	callback = function(event)
		local buf = event.buf

		-- Skip if buffer is not a file or is modified
		if vim.bo[buf].buftype ~= "" or vim.bo[buf].modified then
			return
		end

		-- Skip if file doesn't exist
		local file_path = vim.api.nvim_buf_get_name(buf)
		if file_path == "" or vim.fn.filereadable(file_path) == 0 then
			return
		end

		-- Check if file has been modified externally
		vim.cmd("checktime")
	end,
})

-- Auto-reload files when they change externally (only if buffer is unmodified)
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	group = file_reload_group,
	desc = "Notify when file is reloaded due to external changes",
	callback = function()
		local file_name = vim.fn.expand("<afile>")
		vim.notify("File reloaded: " .. vim.fn.fnamemodify(file_name, ":~"), vim.log.levels.INFO, {
			title = "File Auto-Reload",
			timeout = 2000,
		})
	end,
})

-- Handle tmux focus events properly
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
	group = file_reload_group,
	desc = "Handle tmux focus detection",
	callback = function()
		-- Force a redraw to ensure proper focus detection in tmux
		vim.cmd("redraw!")
	end,
})

-- Terminal focus handling for better tmux integration
vim.api.nvim_create_autocmd("TermEnter", {
	group = file_reload_group,
	desc = "Handle terminal enter events in tmux",
	callback = function()
		-- Check for file changes when entering terminal mode
		vim.schedule(function()
			vim.cmd("checktime")
		end)
	end,
})

-- Disable document highlight for file types that often cause issues
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text", "txt", "help", "log", "json", "yaml", "toml", "conf" },
	callback = function(args)
		-- Clear any existing document highlight autocommands for this buffer
		-- Use pcall to safely clear autocmds that might not exist
		pcall(vim.api.nvim_clear_autocmds, {
			group = "lsp-document-highlight-" .. args.buf,
			buffer = args.buf,
		})
	end,
	desc = "Disable document highlight for specific file types",
})

-- Auto-indent and split tags on <CR> in HTML-like files
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "html", "xml", "typescriptreact", "javascriptreact", "tsx", "jsx", "astro" },
	callback = function()
		vim.keymap.set("i", "<CR>", function()
			local row, col = unpack(vim.api.nvim_win_get_cursor(0))
			local line = vim.api.nvim_get_current_line()
			if col > 0 and line:sub(col, col) == ">" and line:sub(col + 1, col + 1) == "<" then
				return "<CR><CR><Up><C-f>"
			else
				return "<CR>"
			end
		end, {
			expr = true,
			buffer = true,
		})
	end,
})

-- Window management for better tmux integration
local window_group = vim.api.nvim_create_augroup("window-management", {
	clear = true,
})

-- Automatically equalize splits when terminal is resized
vim.api.nvim_create_autocmd("VimResized", {
	group = window_group,
	desc = "Automatically equalize splits when terminal is resized",
	callback = function()
		vim.cmd("wincmd =")
	end,
})

-- Focus events for better tmux pane switching
vim.api.nvim_create_autocmd("WinEnter", {
	group = window_group,
	desc = "Handle window focus events",
	callback = function()
		-- Update window-local options when entering a window
		vim.wo.cursorline = true
	end,
})

vim.api.nvim_create_autocmd("WinLeave", {
	group = window_group,
	desc = "Handle window leave events",
	callback = function()
		-- Dim cursor line when leaving a window
		vim.wo.cursorline = false
	end,
})

-- Auto-trim trailing whitespace on save (for mini.trailspace)
local trailspace_group = vim.api.nvim_create_augroup("trailspace-management", {
	clear = true,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = trailspace_group,
	pattern = "*",
	callback = function()
		-- Skip certain filetypes where trailing whitespace might be meaningful
		local skip_filetypes = { "markdown", "text", "diff", "gitcommit" }

		if not vim.tbl_contains(skip_filetypes, vim.bo.filetype) then
			require("mini.trailspace").trim()
		end
	end,
	desc = "Trim trailing whitespace on save",
})

-- Mini.files enhanced keybindings
local minifiles_group = vim.api.nvim_create_augroup("minifiles-enhanced", {
	clear = true,
})

vim.api.nvim_create_autocmd("User", {
	group = minifiles_group,
	pattern = "MiniFilesBufferCreate",
	callback = function(args)
		local buf_id = args.data.buf_id

		-- Add custom keybindings for this buffer
		vim.keymap.set("n", "<C-s>", function()
			require("mini.files").synchronize()
		end, {
			buffer = buf_id,
			desc = "Synchronize changes (save/create files)",
		})
	end,
	desc = "Set up mini.files buffer keybindings",
})

-- CMP Java snippets loading
local cmp_group = vim.api.nvim_create_augroup("cmp-java-snippets", {
	clear = true,
})

vim.api.nvim_create_autocmd("FileType", {
	group = cmp_group,
	pattern = "java",
	callback = function()
		require("config.snippets").setup()
	end,
	desc = "Load Java snippets for CMP",
})

-- Wiki mdbook automation
local wiki_automation_group = vim.api.nvim_create_augroup("wiki-mdbook-automation", {
	clear = true,
})

-- Modern mdbook SUMMARY.md generator
local function generate_wiki_summary()
	local wiki_root = "/mnt/share/wiki"
	local summary_file = wiki_root .. "/SUMMARY.md"

	-- Ensure wiki directory exists
	if vim.fn.isdirectory(wiki_root) == 0 then
		vim.notify("Wiki directory not found: " .. wiki_root, vim.log.levels.WARN, {
			title = "Wiki Summary",
			timeout = 3000,
		})
		return false
	end

	-- Helper function to create title from filename
	local function title_from_file(filepath)
		local basename = vim.fn.fnamemodify(filepath, ":t:r")
		-- Replace dashes and underscores with spaces, then capitalize each word
		return basename:gsub("[_-]", " "):gsub("%f[%a]%l", string.upper)
	end

	-- Helper function to get relative path from wiki root
	local function relative_path(filepath)
		return filepath:gsub("^" .. vim.pesc(wiki_root .. "/"), "")
	end

	-- Helper function to safely scan directory
	local function scan_directory(dir, pattern, max_depth)
		local files = {}
		local depth = max_depth or 1

		if vim.fn.isdirectory(dir) == 0 then
			return files
		end

		-- Use vim.fs.find for modern file scanning
		local found_files = vim.fs.find(function(name, path)
			return name:match(pattern) and vim.fn.isdirectory(path .. "/" .. name) == 0
		end, {
			path = dir,
			type = "file",
			limit = math.huge,
		})

		-- Filter by depth and sort
		for _, file in ipairs(found_files) do
			local rel_path = file:gsub("^" .. vim.pesc(dir .. "/"), "")
			local file_depth = select(2, rel_path:gsub("/", ""))

			if file_depth < depth then
				table.insert(files, file)
			end
		end

		table.sort(files)
		return files
	end

	-- Start building the summary content
	local summary_lines = { "# Summary", "" }

	-- Add top-level md files (excluding SUMMARY.md and templates)
	local top_level_files = scan_directory(wiki_root, "%.md$", 1)

	for _, file in ipairs(top_level_files) do
		local filename = vim.fn.fnamemodify(file, ":t")
		if filename ~= "SUMMARY.md" and not file:match("/templates/") then
			local rel_path = relative_path(file)
			local title = title_from_file(file)
			table.insert(summary_lines, string.format("- [%s](%s)", title, rel_path))
		end
	end

	-- Handle projects folder specially
	local projects_dir = wiki_root .. "/projects"
	if vim.fn.isdirectory(projects_dir) == 1 then
		-- Ensure projects index exists
		local projects_index = projects_dir .. "/index.md"
		if vim.fn.filereadable(projects_index) == 0 then
			local index_content = { "# Projects Index", "", "Welcome to the projects section." }
			vim.fn.writefile(index_content, projects_index)
		end

		-- Add projects section
		table.insert(summary_lines, "- [Projects](projects/index.md)")

		-- Get project files (excluding index.md)
		local project_files = scan_directory(projects_dir, "%.md$", 1)

		for _, proj_file in ipairs(project_files) do
			local filename = vim.fn.fnamemodify(proj_file, ":t")
			if filename ~= "index.md" then
				local proj_rel = relative_path(proj_file)
				local proj_title = title_from_file(proj_file)
				table.insert(summary_lines, string.format("  - [%s](%s)", proj_title, proj_rel))

				-- Check for nested folder with same name as project (without extension)
				local project_name = vim.fn.fnamemodify(proj_file, ":t:r")
				local nested_dir = projects_dir .. "/" .. project_name

				if vim.fn.isdirectory(nested_dir) == 1 then
					local nested_files = scan_directory(nested_dir, "%.md$", math.huge)

					for _, nested_file in ipairs(nested_files) do
						local nested_rel = relative_path(nested_file)
						local nested_title = title_from_file(nested_file)
						table.insert(summary_lines, string.format("    - [%s](%s)", nested_title, nested_rel))
					end
				end
			end
		end
	end

	-- Handle diary folder specially
	local diary_dir = wiki_root .. "/diary"
	if vim.fn.isdirectory(diary_dir) == 1 then
		-- Ensure diary index exists
		local diary_index = diary_dir .. "/index.md"
		if vim.fn.filereadable(diary_index) == 0 then
			local index_content = { "# Diary Index", "", "Personal journal entries." }
			vim.fn.writefile(index_content, diary_index)
		end

		-- Add diary section
		table.insert(summary_lines, "- [Diary](diary/index.md)")

		-- Get diary files (excluding index.md) and sort by date (newest first for diary)
		local diary_files = scan_directory(diary_dir, "%.md$", math.huge)

		-- Filter out index.md and sort diary files by filename (which should be dates)
		local filtered_diary_files = {}
		for _, diary_file in ipairs(diary_files) do
			local filename = vim.fn.fnamemodify(diary_file, ":t")
			if filename ~= "index.md" then
				table.insert(filtered_diary_files, diary_file)
			end
		end

		-- Sort diary files in reverse order (newest first) since they're typically dated
		table.sort(filtered_diary_files, function(a, b)
			local filename_a = vim.fn.fnamemodify(a, ":t")
			local filename_b = vim.fn.fnamemodify(b, ":t")
			return filename_a > filename_b -- Reverse sort for diary entries
		end)

		-- Add diary entries with special formatting for dates
		for _, diary_file in ipairs(filtered_diary_files) do
			local diary_rel = relative_path(diary_file)
			local filename = vim.fn.fnamemodify(diary_file, ":t:r")

			-- Special title formatting for diary entries (check if it's a date format)
			local diary_title
			if filename:match("^%d%d%d%d%-%d%d%-%d%d$") then
				-- It's a date format YYYY-MM-DD, format it nicely
				local year, month, day = filename:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
				local months = {
					"01",
					"January",
					"02",
					"February",
					"03",
					"March",
					"04",
					"April",
					"05",
					"May",
					"06",
					"June",
					"07",
					"July",
					"08",
					"August",
					"09",
					"September",
					"10",
					"October",
					"11",
					"November",
					"12",
					"December",
				}
				local month_name = months[tonumber(month) * 2] or month
				diary_title = string.format("%s %d, %s", month_name, tonumber(day), year)
			else
				-- Use regular title formatting
				diary_title = title_from_file(diary_file)
			end

			table.insert(summary_lines, string.format("  - [%s](%s)", diary_title, diary_rel))
		end
	end

	-- Write the summary file
	local success, err = pcall(vim.fn.writefile, summary_lines, summary_file)
	if not success then
		vim.notify("Failed to write SUMMARY.md: " .. tostring(err), vim.log.levels.ERROR, {
			title = "Wiki Summary",
			timeout = 5000,
		})
		return false
	end

	vim.notify("Generated SUMMARY.md with " .. (#summary_lines - 2) .. " entries", vim.log.levels.INFO, {
		title = "Wiki Summary",
		timeout = 2000,
	})
	return true
end

-- Debounced summary generation to avoid excessive updates
local summary_timer = nil
local function debounced_summary_generation()
	if summary_timer then
		vim.fn.timer_stop(summary_timer)
	end

	summary_timer = vim.fn.timer_start(1000, function()
		generate_wiki_summary()
		summary_timer = nil
	end)
end

-- Auto-generate summary when wiki files are created or modified
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	group = wiki_automation_group,
	pattern = { "/mnt/share/wiki/*.md", "/mnt/share/wiki/**/*.md" },
	callback = function(event)
		local file_path = event.file

		-- Skip SUMMARY.md itself to avoid infinite loops
		if file_path:match("SUMMARY%.md$") then
			return
		end

		-- Skip temporary files
		if file_path:match("%.tmp$") or file_path:match("%.swp$") or file_path:match("/%.") then
			return
		end

		debounced_summary_generation()
	end,
	desc = "Auto-generate wiki summary when markdown files are saved",
})

-- Auto-generate summary when new wiki files are created
vim.api.nvim_create_autocmd({ "BufNewFile" }, {
	group = wiki_automation_group,
	pattern = { "/mnt/share/wiki/*.md", "/mnt/share/wiki/**/*.md" },
	callback = function(event)
		local file_path = event.file

		-- Skip SUMMARY.md
		if file_path:match("SUMMARY%.md$") then
			return
		end

		-- Generate summary after the file is actually written
		vim.api.nvim_create_autocmd("BufWritePost", {
			buffer = event.buf,
			once = true,
			callback = function()
				debounced_summary_generation()
			end,
		})
	end,
	desc = "Auto-generate wiki summary when new markdown files are created",
})

-- Manual summary generation command
vim.api.nvim_create_user_command("WikiSummary", function()
	vim.notify("Generating wiki summary...", vim.log.levels.INFO, {
		title = "Wiki Summary",
		timeout = 1000,
	})
	generate_wiki_summary()
end, {
	desc = "Manually generate wiki SUMMARY.md",
})

-- Manual wiki build command
vim.api.nvim_create_user_command("WikiBuild", function()
	local wiki_dir = "/mnt/share/wiki"

	vim.notify("Building wiki manually...", vim.log.levels.INFO, {
		title = "Wiki Build",
		timeout = 2000,
	})

	vim.fn.jobstart({ "mdbook", "build", wiki_dir }, {
		cwd = wiki_dir,
		on_exit = function(_, exit_code)
			if exit_code == 0 then
				vim.notify("Wiki built successfully", vim.log.levels.INFO, {
					title = "Wiki Build",
					timeout = 2000,
				})
			else
				vim.notify("Wiki build failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR, {
					title = "Wiki Build",
					timeout = 5000,
				})
			end
		end,
		on_stderr = function(_, data)
			if data and #data > 0 then
				local error_msg = table.concat(data, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
				if error_msg ~= "" then
					vim.notify("Wiki build error: " .. error_msg, vim.log.levels.ERROR, {
						title = "Wiki Build",
						timeout = 5000,
					})
				end
			end
		end,
		stdout_buffered = true,
		stderr_buffered = true,
	})
end, {
	desc = "Manually build wiki with mdbook",
})

-- Clean wiki build command
vim.api.nvim_create_user_command("WikiClean", function()
	local wiki_dir = "/mnt/share/wiki"

	vim.notify("Cleaning wiki build...", vim.log.levels.INFO, {
		title = "Wiki Clean",
		timeout = 2000,
	})

	-- Use rm -rf to clean the book directory since mdbook clean might not work reliably
	vim.fn.jobstart({ "sh", "-c", 'cd "' .. wiki_dir .. '" && rm -rf book/' }, {
		on_exit = function(_, exit_code)
			if exit_code == 0 then
				vim.notify("Wiki build directory cleaned successfully", vim.log.levels.INFO, {
					title = "Wiki Clean",
					timeout = 2000,
				})
			else
				vim.notify("Wiki clean failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR, {
					title = "Wiki Clean",
					timeout = 5000,
				})
			end
		end,
	})
end, {
	desc = "Clean wiki build directory",
})
