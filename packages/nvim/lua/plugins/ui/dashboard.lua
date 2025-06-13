-- Telescope file browser replaces dashboard
-- Opens file browser when starting nvim with no arguments
return {
    'nvim-telescope/telescope-file-browser.nvim',
    lazy = false,
    dependencies = {'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim'},
    config = function()
        -- More aggressive auto-open file browser when no arguments
        vim.api.nvim_create_autocmd('VimEnter', {
            group = vim.api.nvim_create_augroup('FileExplorerStart', {
                clear = true
            }),
            callback = function()
                -- Only trigger for no arguments
                if vim.fn.argc() == 0 then
                    vim.schedule(function()
                        -- Wait a bit more to ensure buffer cleanup is complete
                        vim.defer_fn(function()
                            -- Force delete any remaining problematic buffers
                            local buffers = vim.api.nvim_list_bufs()
                            for _, buf in ipairs(buffers) do
                                if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
                                    local bufname = vim.api.nvim_buf_get_name(buf)
                                    local buftype = vim.api.nvim_get_option_value('buftype', {
                                        buf = buf
                                    })

                                    -- Delete any normal buffers (including directory buffers and unnamed ones)
                                    if buftype == '' and
                                        (bufname == '' or bufname:match('/$') or bufname == vim.fn.getcwd()) then
                                        pcall(vim.api.nvim_buf_delete, buf, {
                                            force = true
                                        })
                                    end
                                end
                            end

                            -- Now open the file browser
                            require('telescope').extensions.file_browser.file_browser({
                                cwd = vim.fn.getcwd(),
                                respect_gitignore = false,
                                hidden = true,
                                grouped = true,
                                previewer = false,
                                initial_mode = 'normal',
                                prompt_title = 'File Browser',
                                layout_config = {
                                    height = 0.8,
                                    width = 0.8
                                }
                            })
                        end, 150) -- Longer delay to ensure everything is ready
                    end)
                end
            end
        })
    end
}
