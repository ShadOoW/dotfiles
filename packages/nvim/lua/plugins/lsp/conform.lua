return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	dependencies = { "williamboman/mason.nvim" },
	opts = {
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			-- Web Development - JavaScript/TypeScript
			javascript = { "biome", "prettierd", "prettier" },
			javascriptreact = { "biome", "prettierd", "prettier" },
			typescript = { "biome", "prettierd", "prettier" },
			typescriptreact = { "biome", "prettierd", "prettier" },
			vue = { "prettierd", "prettier" },
			svelte = { "prettierd", "prettier" },

			-- Web Development - HTML/CSS
			html = { "prettierd", "prettier" },
			css = { "prettierd", "prettier" },
			scss = { "prettierd", "prettier" },
			less = { "prettierd", "prettier" },

			-- Modern Web Frameworks
			astro = { "prettierd", "prettier" },

			-- Data & Config
			json = { "biome", "prettierd", "prettier" },
			jsonc = { "biome", "prettierd", "prettier" },
			json5 = { "prettierd", "prettier" },
			yaml = { "prettierd", "prettier" },
			yml = { "prettierd", "prettier" },
			toml = { "taplo" },
			xml = { "xmlformat", "prettierd", "prettier" },

			-- Documentation
			markdown = { "prettierd", "prettier" },
			mdx = { "prettierd", "prettier" },

			-- Lua
			lua = { "stylua" },

			-- Java
			java = { "google-java-format" },

			-- Python
			python = { "isort", "black" },

			-- Shell
			sh = { "shfmt" },
			bash = { "shfmt" },
			zsh = { "shfmt" },

			-- Go
			go = { "gofumpt", "goimports" },

			-- Rust
			rust = { "rustfmt" },

			-- C/C++
			c = { "clang-format" },
			cpp = { "clang-format" },

			-- SQL
			sql = { "sql-formatter" },

			-- Docker
			dockerfile = { "prettier" },
		},

		formatters = {
			-- Enhanced Prettier daemon for speed
			prettierd = {
				env = {
					PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/prettier/.prettierrc.json"),
				},
			},

			-- Biome for fast JS/TS formatting
			biome = {
				command = "biome",
				args = { "format", "--stdin-file-path", "$FILENAME" },
				stdin = true,
			},

			-- Tailwind class sorting
			rustywind = {
				command = "rustywind",
				args = { "--stdin" },
				stdin = true,
			},

			-- Enhanced stylua for Lua
			stylua = {
				prepend_args = {
					"--column-width",
					"120",
					"--collapse-simple-statement",
					"Never",
					"--indent-width",
					"2",
					"--indent-type",
					"Spaces",
					"--quote-style",
					"ForceQuote",
				},
			},

			-- Java formatting
			["google-java-format"] = {
				command = "google-java-format",
				args = { "--aosp", "-" },
				stdin = true,
			},

			-- Shell formatting
			shfmt = {
				prepend_args = { "-i", "2", "-bn", "-ci", "-sr" },
			},

			-- Go formatting
			gofumpt = {
				command = "gofumpt",
				args = { "-w", "$FILENAME" },
				stdin = false,
			},

			goimports = {
				command = "goimports",
				args = { "-w", "$FILENAME" },
				stdin = false,
			},

			-- SQL formatting
			["sql-formatter"] = {
				command = "sql-formatter",
				args = { "--language", "postgresql", "--tab-width", "2", "--keyword-case", "upper" },
				stdin = true,
			},

			-- C/C++ formatting
			["clang-format"] = {
				prepend_args = { "--style=Google" },
			},

			-- XML formatting
			xmlformat = {
				command = "xmlformat",
				args = { "--indent", "2", "--preserve", "literal" },
				stdin = true,
			},

			-- TOML formatting
			taplo = {
				command = "taplo",
				args = { "format", "-" },
				stdin = true,
			},
		},

		-- Custom format options
		format_after_save = function(bufnr)
			-- Auto-sort Tailwind classes after save
			local ft = vim.bo[bufnr].filetype
			if
				vim.tbl_contains({
					"html",
					"css",
					"javascript",
					"typescript",
					"javascriptreact",
					"typescriptreact",
					"vue",
					"svelte",
					"astro",
				}, ft)
			then
				local conform = require("conform")
				conform.format({
					bufnr = bufnr,
					formatters = { "rustywind" },
					quiet = true,
				})
			end
		end,
	},

	config = function(_, opts)
		local conform = require("conform")
		conform.setup(opts)

		-- Enhanced keymaps
		vim.keymap.set({ "n", "v" }, "<leader>ff", function()
			conform.format({
				async = true,
				lsp_format = "fallback",
				timeout_ms = 2000,
			})
		end, {
			desc = "Format file/range",
		})

		-- Format with specific formatter
		vim.keymap.set({ "n", "v" }, "<leader>fF", function()
			local formatters = conform.list_formatters()
			if #formatters == 0 then
				vim.notify("No formatters available for this buffer", vim.log.levels.WARN)
				return
			end

			local formatter_names = vim.tbl_map(function(f)
				return f.name
			end, formatters)
			vim.ui.select(formatter_names, {
				prompt = "Select formatter:",
			}, function(choice)
				if choice then
					conform.format({
						formatters = { choice },
						async = true,
						timeout_ms = 2000,
					})
				end
			end)
		end, {
			desc = "Format with specific formatter",
		})

		-- Toggle format on save
		vim.keymap.set("n", "<leader>tf", function()
			if vim.g.disable_autoformat or vim.b.disable_autoformat then
				vim.g.disable_autoformat = false
				vim.b.disable_autoformat = false
				vim.notify("Format on save enabled", vim.log.levels.INFO)
			else
				vim.g.disable_autoformat = true
				vim.notify("Format on save disabled", vim.log.levels.INFO)
			end
		end, {
			desc = "Toggle format on save",
		})

		-- Command to show available formatters
		vim.api.nvim_create_user_command("ConformInfo", function()
			local formatters = conform.list_formatters()
			if #formatters == 0 then
				print("No formatters available for this buffer")
				return
			end

			print("Available formatters for " .. vim.bo.filetype .. ":")
			for _, formatter in ipairs(formatters) do
				local status = formatter.available and "✓" or "✗"
				print(string.format("  %s %s", status, formatter.name))
			end
		end, {
			desc = "Show available formatters",
		})
	end,
}
