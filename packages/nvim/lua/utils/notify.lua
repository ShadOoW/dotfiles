-- Centralized notification utility
-- This module provides a consistent interface for all notifications in the config
-- It wraps nvim-notify with additional functionality and ensures UI consistency
local M = {}

-- Cache for the notify plugin
local notify = nil

-- Initialize the notification system
function M.setup()
	-- Ensure nvim-notify is available
	local ok, nvim_notify = pcall(require, "notify")
	if not ok then
		-- Fallback to vim.notify if nvim-notify is not available
		notify = vim.notify
		return
	end

	notify = nvim_notify

	-- Enhanced configuration for modern, clean UI
	notify.setup({
		-- Animation style - smooth and modern
		stages = "fade_in_slide_out",

		-- Timeout configuration
		timeout = 3000,
		max_height = function()
			return math.floor(vim.o.lines * 0.75)
		end,
		max_width = function()
			return math.floor(vim.o.columns * 0.75)
		end,

		-- Modern background with transparency
		background_colour = "Normal",

		-- Clean, modern icons
		icons = {
			ERROR = "󰅚",
			WARN = "󰀪",
			INFO = "󰋽",
			DEBUG = "󰃤",
			TRACE = "󰛮",
		},

		-- Consistent sizing
		minimum_width = 50,
		maximum_width = 100,

		-- Show appropriate levels
		level = vim.log.levels.INFO,

		-- Modern window styling
		on_open = function(win)
			local config = vim.api.nvim_win_get_config(win)
			config.border = "rounded"
			config.zindex = 175
			vim.api.nvim_win_set_config(win, config)
		end,

		-- Clean rendering
		render = "wrapped-compact",

		-- Position - top down for better visibility
		top_down = true,
	})

	-- Override vim.notify to use our enhanced version
	vim.notify = notify
end

-- Enhanced notification functions with consistent styling and behavior

-- Core notification function with enhanced options
function M.notify(message, level, opts)
	opts = opts or {}
	level = level or vim.log.levels.INFO

	-- Ensure notify is initialized
	if not notify then
		M.setup()
	end

	-- Enhanced default options
	local enhanced_opts = vim.tbl_deep_extend("force", {
		title = opts.title or "Neovim",
		timeout = opts.timeout or M._get_timeout_for_level(level),
		animate = opts.animate ~= false,
		hide_from_history = opts.hide_from_history or false,
	}, opts)

	-- Format message for better readability
	message = M._format_message(message, level)

	notify(message, level, enhanced_opts)
end

-- Specialized notification functions

-- Success notifications (green theme)
function M.success(message, opts)
	opts = opts or {}
	opts.title = opts.title or "✅ Success"
	M.notify(message, vim.log.levels.INFO, opts)
end

-- Warning notifications (yellow theme)
function M.warn(message, opts)
	opts = opts or {}
	opts.title = opts.title or "⚠️  Warning"
	M.notify(message, vim.log.levels.WARN, opts)
end

-- Error notifications (red theme)
function M.error(message, opts)
	opts = opts or {}
	opts.title = opts.title or "❌ Error"
	opts.timeout = opts.timeout or 5000 -- Longer timeout for errors
	M.notify(message, vim.log.levels.ERROR, opts)
end

-- Info notifications (blue theme)
function M.info(message, opts)
	opts = opts or {}
	opts.title = opts.title or "ℹ️  Info"
	M.notify(message, vim.log.levels.INFO, opts)
end

-- Debug notifications (gray theme)
function M.debug(message, opts)
	opts = opts or {}
	opts.title = opts.title or "🐛 Debug"
	M.notify(message, vim.log.levels.DEBUG, opts)
end

-- Build system notifications
function M.build_started(project_name)
	M.info(string.format("Building %s...", project_name or "project"), {
		title = "🔨 Build Started",
		timeout = 2000,
	})
end

function M.build_success(project_name, duration)
	local message = string.format("Build successful for %s", project_name or "project")
	if duration then
		message = message .. string.format(" (%.1fs)", duration)
	end

	M.success(message, {
		title = "🔨 Build Complete",
		timeout = 3000,
	})
end

function M.build_failed(project_name, error_msg)
	local message = string.format("Build failed for %s", project_name or "project")
	if error_msg then
		message = message .. "\n" .. error_msg
	end

	M.error(message, {
		title = "🔨 Build Failed",
		timeout = 5000,
	})
end

-- Test system notifications
function M.test_started(test_name)
	M.info(string.format("Running tests: %s", test_name or "all"), {
		title = "🧪 Tests Started",
		timeout = 2000,
	})
end

function M.test_passed(passed, total, duration)
	local message = string.format("%d/%d tests passed", passed, total)
	if duration then
		message = message .. string.format(" (%.1fs)", duration)
	end

	M.success(message, {
		title = "🧪 Tests Passed",
		timeout = 3000,
	})
end

function M.test_failed(failed, total, duration)
	local message = string.format("%d/%d tests failed", failed, total)
	if duration then
		message = message .. string.format(" (%.1fs)", duration)
	end

	M.error(message, {
		title = "🧪 Tests Failed",
		timeout = 5000,
	})
end

-- LSP notifications
function M.lsp_attached(client_name, buffer_name)
	M.info(string.format("%s attached to %s", client_name, buffer_name or "buffer"), {
		title = "🔧 LSP Attached",
		timeout = 2000,
	})
end

function M.lsp_detached(client_name)
	M.warn(string.format("%s detached", client_name), {
		title = "🔧 LSP Detached",
		timeout = 2000,
	})
end

function M.lsp_error(client_name, error_msg)
	M.error(string.format("%s error: %s", client_name, error_msg), {
		title = "🔧 LSP Error",
		timeout = 5000,
	})
end

-- Debug notifications
function M.debug_started(config_name)
	M.info(string.format("Debug session started: %s", config_name or "default"), {
		title = "🐛 Debug Started",
		timeout = 2000,
	})
end

function M.debug_stopped()
	M.info("Debug session stopped", {
		title = "🐛 Debug Stopped",
		timeout = 2000,
	})
end

function M.debug_breakpoint_hit(file, line)
	M.info(string.format("Breakpoint hit at %s:%d", vim.fn.fnamemodify(file, ":t"), line), {
		title = "🐛 Breakpoint Hit",
		timeout = 3000,
	})
end

-- Project notifications
function M.project_switched(project_name, project_type)
	local icon_map = {
		gradle = "📦",
		maven = "📦",
		node = "📦",
		rust = "🦀",
		python = "🐍",
		go = "🐹",
		java = "☕",
		javascript = "🟨",
		typescript = "🔷",
		default = "📁",
	}

	local icon = icon_map[project_type] or icon_map.default
	M.info(string.format("Switched to %s", project_name), {
		title = string.format("%s Project Switched", icon),
		timeout = 2000,
	})
end

-- Git notifications
function M.git_branch_switched(branch_name)
	M.info(string.format("Switched to branch: %s", branch_name), {
		title = " Git Branch",
		timeout = 2000,
	})
end

function M.git_commit_success(commit_hash)
	M.success(string.format("Commit successful: %s", commit_hash:sub(1, 7)), {
		title = " Git Commit",
		timeout = 3000,
	})
end

-- File operation notifications
function M.file_saved(filename)
	M.info(string.format("Saved: %s", vim.fn.fnamemodify(filename, ":t")), {
		title = "💾 File Saved",
		timeout = 1000,
	})
end

function M.file_formatted(formatter_name)
	M.success(string.format("Formatted with %s", formatter_name), {
		title = "✨ File Formatted",
		timeout = 1500,
	})
end

-- Plugin notifications
function M.plugin_loaded(plugin_name)
	M.info(string.format("Loaded: %s", plugin_name), {
		title = "🔌 Plugin Loaded",
		timeout = 1000,
	})
end

function M.plugin_error(plugin_name, error_msg)
	M.error(string.format("Error loading %s: %s", plugin_name, error_msg), {
		title = "🔌 Plugin Error",
		timeout = 5000,
	})
end

-- Utility functions
function M.dismiss_all()
	if notify and type(notify.dismiss) == "function" then
		notify.dismiss({
			silent = true,
			pending = true,
		})
	end
end

function M.show_history()
	local ok, telescope = pcall(require, "telescope")
	if not ok then
		M.warn("Telescope not available for notification history")
		return
	end

	local themes = require("telescope.themes")
	telescope.extensions.notify.notify(themes.get_ivy({
		prompt_title = "📜 Notification History",
		layout_config = {
			height = 0.4,
			preview_cutoff = 120,
		},
	}))
end

-- Private helper functions
function M._get_timeout_for_level(level)
	local timeouts = {
		[vim.log.levels.ERROR] = 5000,
		[vim.log.levels.WARN] = 3000,
		[vim.log.levels.INFO] = 2000,
		[vim.log.levels.DEBUG] = 1500,
	}
	return timeouts[level] or 2000
end

function M._format_message(message, level)
	-- Ensure message is a string
	if type(message) ~= "string" then
		message = vim.inspect(message)
	end

	-- Clean up the message
	message = message:gsub("^%s+", ""):gsub("%s+$", "")

	return message
end

-- Export module for consistent usage
_G.NotifyUtil = M

return M
