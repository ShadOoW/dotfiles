return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Configure markdownlint-cli2 as a custom linter
		lint.linters.markdownlint_cli2 = {
			cmd = "markdownlint-cli2",
			stdin = true,
			args = { "--stdin" },
			stream = "stderr",
			ignore_exitcode = true,
			parser = function(output)
				local items = {}
				for line in output:gmatch("[^\r\n]+") do
					-- Parse markdownlint-cli2 output format
					local file, line_num, col, rule, message = line:match("(.+):(%d+):?(%d*) ([%w-]+) (.+)")
					if file and line_num and rule and message then
						table.insert(items, {
							lnum = tonumber(line_num) - 1,
							col = col and tonumber(col) or 0,
							message = message,
							code = rule,
							severity = vim.diagnostic.severity.WARN,
							source = "markdownlint-cli2",
						})
					end
				end
				return items
			end,
		}

		lint.linters_by_ft = {
			markdown = { "markdownlint_cli2" },
		}

		-- Create autocommand which carries out the actual linting
		-- on the specified events.
		local lint_augroup = vim.api.nvim_create_augroup("lint", {
			clear = true,
		})
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				-- Only run the linter in buffers that you can modify in order to
				-- avoid superfluous noise, notably within the handy LSP pop-ups that
				-- describe the hovered symbol using Markdown.
				if vim.bo.modifiable then
					lint.try_lint()
				end
			end,
		})
	end,
}
