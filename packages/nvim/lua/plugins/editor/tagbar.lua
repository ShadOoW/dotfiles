return {
    'preservim/tagbar',
    cmd = 'TagbarToggle',
    keys = {{
        '<F8>',
        '<cmd>TagbarToggle<cr>',
        desc = 'Toggle Tagbar'
    }},
    init = function()
        -- Configure Tagbar
        vim.g.tagbar_compact = 1 -- Remove help text and blank lines
        vim.g.tagbar_sort = 0 -- Sort by order in file (not by name)
        vim.g.tagbar_show_data_type = 1 -- Show data type of variables
        vim.g.tagbar_show_visibility = 1 -- Show visibility symbols (public/private)
        vim.g.tagbar_indent = 1 -- Number of spaces to indent nested items
        vim.g.tagbar_show_linenumbers = 0 -- Don't show line numbers
        vim.g.tagbar_width = 30 -- Width of the Tagbar window
        vim.g.tagbar_zoomwidth = 0 -- Don't zoom to longest tag
        vim.g.tagbar_autoclose = 0 -- Don't close when jumping to a tag
        vim.g.tagbar_autofocus = 1 -- Focus the Tagbar window when opened
        vim.g.tagbar_position = 'right' -- Position Tagbar on the right

        -- File type specific settings
        vim.g.tagbar_type_lua = {
            ctagstype = 'lua',
            kinds = {'m:modules', 'f:functions', 'v:variables', 'c:classes'}
        }

        vim.g.tagbar_type_markdown = {
            ctagstype = 'markdown',
            kinds = {'h:headings', 'l:links', 'i:images'}
        }

        vim.g.tagbar_type_yaml = {
            ctagstype = 'yaml',
            kinds = {'a:anchors', 's:section', 'e:entry'}
        }
    end
}
