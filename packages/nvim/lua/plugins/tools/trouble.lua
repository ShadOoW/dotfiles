return {
    'folke/trouble.nvim',
    cmd = {'Trouble', 'TroubleToggle', 'TroubleRefresh', 'TroubleClose', 'TroubleNext', 'TroublePrev', 'TroubleFirst',
           'TroubleLast'},
    dependencies = {'nvim-tree/nvim-web-devicons'},
    keys = {{
        '<leader>xx',
        '<cmd>TroubleToggle<CR>',
        desc = 'Toggle Trouble'
    }, {
        '<leader>xw',
        '<cmd>TroubleToggle workspace_diagnostics<CR>',
        desc = 'Workspace Diagnostics'
    }, {
        '<leader>xd',
        '<cmd>TroubleToggle document_diagnostics<CR>',
        desc = 'Document Diagnostics'
    }, {
        '<leader>xq',
        '<cmd>TroubleToggle quickfix<CR>',
        desc = 'Quickfix List'
    }, {
        '<leader>xl',
        '<cmd>TroubleToggle loclist<CR>',
        desc = 'Location List'
    }, {
        'gR',
        '<cmd>TroubleToggle lsp_references<CR>',
        desc = 'LSP References'
    }},
    opts = {
        use_diagnostic_signs = true
    }
}
