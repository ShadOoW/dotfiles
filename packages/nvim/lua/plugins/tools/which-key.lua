return {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
        delay = 0,
        icons = {
            mappings = vim.g.have_nerd_font,
            keys = vim.g.have_nerd_font and {} or {
                Up = '<Up> ',
                Down = '<Down> ',
                Left = '<Left> ',
                Right = '<Right> '
                -- Add more key mappings as needed
            }
        },
        spec = {{
            '<leader>s',
            group = '[S]earch'
        }, {
            '<leader>t',
            group = '[T]oggle'
        }, {
            '<leader>h',
            group = 'Git [H]unk',
            mode = {'n', 'v'}
        }}
    }
}
