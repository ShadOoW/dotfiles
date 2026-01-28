-- Markdown filetype settings
-- This file is automatically loaded for *.md and 'markdown' buffers
-- Core markdown UI behavior
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = 'nc'
vim.opt_local.modifiable = true
vim.opt_local.wrap = true

-- Protect conceallevel from being changed by other plugins for this buffer
local markdown_group = vim.api.nvim_create_augroup('MarkdownSettingsBuffer', {
    clear = false
})

vim.api.nvim_create_autocmd({'ModeChanged', 'CmdlineEnter', 'CmdlineLeave'}, {
    group = markdown_group,
    buffer = 0,
    callback = function()
        if vim.opt_local.conceallevel:get() ~= 2 then
            vim.opt_local.conceallevel = 2
            vim.opt_local.concealcursor = 'nc'
        end
    end,
    desc = 'Protect conceallevel=2 in markdown buffers from mode changes'
})
