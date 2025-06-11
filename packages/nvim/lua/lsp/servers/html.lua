-- HTML LSP server configuration
return {
	settings = {
		html = {
			format = {
				templating = true,
				wrapLineLength = 120,
				unformatted = "wbr",
				indentInnerHtml = false,
				preserveNewLines = true,
				maxPreserveNewLines = 2,
				indentHandlebars = false,
				endWithNewline = false,
				extraLiners = "head, body, /html",
				wrapAttributes = "auto",
			},
			hover = {
				documentation = true,
				references = true,
			},
			completion = {
				attributeDefaultValue = "doublequotes",
			},
			validate = true,
			lint = {
				-- Enable comprehensive HTML validation
				enabled = true,
				duplicateIds = "error",
				missingDoctype = "warning",
				missingLang = "warning",
				unusedDefinition = "warning",
				validateEmbeddedScripts = true,
			},
			suggest = {
				html5 = true,
				angular1 = false,
				ionic = false,
			},
			trace = {
				server = "verbose", -- Enable verbose logging for debugging
			},
		},
	},
	filetypes = { "html", "htm" },
	init_options = {
		configurationSection = { "html", "css", "javascript" },
		embeddedLanguages = {
			css = true,
			javascript = true,
		},
		provideFormatter = true,
	},
	capabilities = {
		textDocument = {
			completion = {
				completionItem = {
					snippetSupport = true,
				},
			},
		},
	},
}
