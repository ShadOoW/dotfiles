return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	dependencies = { "williamboman/mason.nvim" },
	event = "VeryLazy",
	config = function()
		require("mason-tool-installer").setup({
			ensure_installed = { -- LSP Servers
				-- Web Development
				"html-lsp", -- HTML
				"css-lsp", -- CSS
				"typescript-language-server", -- TypeScript/JavaScript
				"eslint-lsp", -- ESLint
				"tailwindcss-language-server", -- Tailwind CSS
				"astro-language-server", -- Astro
				"emmet-ls", -- Emmet
				"vtsls", -- Advanced TypeScript/JavaScript (alternative to ts_ls)
				"unocss-language-server", -- UnoCSS
				"svelte-language-server", -- Svelte
				"vue-language-server", -- Vue
				-- Data & Configuration
				"json-lsp", -- JSON
				"yaml-language-server", -- YAML
				"taplo", -- TOML
				-- Markdown & Documentation
				"marksman", -- Markdown
				"harper-ls", -- Grammar checking
				-- General Development
				"lua-language-server", -- Lua
				"bash-language-server", -- Bash
				"dockerfile-language-server", -- Docker
				"docker-compose-language-service", -- Docker Compose
				-- Build Tools & Package Managers
				"gradle-language-server", -- Gradle
				"maven-language-server", -- Maven
				-- Java Development
				"jdtls", -- Java
				-- Linters
				-- Web Development
				"eslint_d", -- Fast ESLint
				"stylelint", -- CSS/SCSS linter
				"htmlhint", -- HTML linter
				"alex", -- Inclusive language linter
				-- General
				"shellcheck", -- Shell script linter
				"vale", -- Prose linter
				"codespell", -- Spell checker
				"gitlint", -- Git commit linter
				"yamllint", -- YAML linter
				"jsonlint", -- JSON linter
				-- Markdown
				"markdownlint", -- Markdown linter
				"textlint", -- Text linter
				-- Formatters
				-- Web Development
				"prettier", -- Universal formatter
				"prettierd", -- Fast Prettier daemon
				"rustywind", -- Tailwind class sorter
				"biome", -- Fast JS/TS/JSON formatter
				-- General
				"stylua", -- Lua formatter
				"shfmt", -- Shell script formatter
				"black", -- Python formatter
				"isort", -- Python import sorter
				"google-java-format", -- Java formatter
				-- CSS/SCSS
				"stylelint-lsp", -- CSS/SCSS formatter
				-- SQL
				"sql-formatter", -- SQL formatter
				-- YAML
				"yamlfix", -- YAML formatter
				-- Debug Adapters
				-- Web Development
				"node-debug2-adapter", -- Node.js debugger
				"js-debug-adapter", -- Modern JS/TS debugger
				"chrome-debug-adapter", -- Chrome/Edge debugger
				"firefox-debug-adapter", -- Firefox debugger
				-- General
				"bash-debug-adapter", -- Bash debugger
				"java-debug-adapter", -- Java debugger
				"java-test", -- Java test runner
				-- Additional Tools
				"tree-sitter-cli", -- Tree-sitter CLI
				"grammarly-languageserver", -- Grammarly integration
				"ltex-ls", -- LaTeX/Markdown grammar checker
			},
			auto_update = true,
			run_on_start = true,
			start_delay = 3000, -- 3 second delay
			debounce_hours = 5, -- at least 5 hours between attempts
		})
	end,
}
