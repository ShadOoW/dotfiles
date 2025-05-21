-- LSP handlers
local M = {}

-- Setup shared capabilities for LSP servers (handled in lsp.setup.lua)
-- M.capabilities = require('cmp_nvim_lsp').default_capabilities() or vim.lsp.protocol.make_client_capabilities()

-- Setup keymaps for LSP
---@param client vim.lsp.Client
---@param bufnr number
function M.on_attach(client, bufnr)
    local keymap = require('utils.keymap')

    -- Create a buffer-specific keymap function
    local function buf_map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, {
            buffer = bufnr,
            desc = 'LSP: ' .. desc
        })
    end

    -- Rename the variable under your cursor
    buf_map('n', 'grn', vim.lsp.buf.rename, '[R]e[n]ame')

    -- Execute a code action
    buf_map('n', 'gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction')
    buf_map('x', 'gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction')

    -- Find references for the word under your cursor
    buf_map('n', 'grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

    -- Jump to the implementation of the word under your cursor
    buf_map('n', 'gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

    -- Jump to the definition of the word under your cursor
    buf_map('n', 'grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

    -- Goto Declaration
    buf_map('n', 'grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- Document symbols
    buf_map('n', 'gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

    -- Workspace symbols
    buf_map('n', 'gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

    -- Type definition
    buf_map('n', 'grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

    -- Inlay hints toggle (if supported)
    if client.supports_method and client.supports_method("textDocument/inlayHint", {
        bufnr = bufnr
    }) then
        -- Enable inlay hints by default
        vim.lsp.inlay_hint.enable(true, {
            bufnr = bufnr
        })

        buf_map('n', '<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({
                bufnr = bufnr
            }))
        end, '[T]oggle Inlay [H]ints')
    end

    -- Document highlight
    if client.supports_method and client.supports_method("textDocument/documentHighlight", {
        bufnr = bufnr
    }) then
        local highlight_group = vim.api.nvim_create_augroup('lsp-document-highlight', {
            clear = false
        })

        vim.api.nvim_create_autocmd({'CursorHold', 'CursorHoldI'}, {
            buffer = bufnr,
            group = highlight_group,
            callback = vim.lsp.buf.document_highlight
        })

        vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
            buffer = bufnr,
            group = highlight_group,
            callback = vim.lsp.buf.clear_references
        })
    end

    -- Format on save if the LSP supports it
    if client.supports_method and client.supports_method("textDocument/formatting") then
        buf_map('n', '<leader>f', function()
            vim.lsp.buf.format({
                async = true
            })
        end, '[F]ormat document')
    end
end

-- Configure diagnostics
function M.setup_diagnostics()
    vim.diagnostic.config({
        severity_sort = true,
        float = {
            border = 'rounded',
            source = 'if_many'
        },
        underline = {
            severity = vim.diagnostic.severity.ERROR
        },
        signs = vim.g.have_nerd_font and {
            text = {
                [vim.diagnostic.severity.ERROR] = '󰅚 ',
                [vim.diagnostic.severity.WARN] = '󰀪 ',
                [vim.diagnostic.severity.INFO] = '󰋽 ',
                [vim.diagnostic.severity.HINT] = '󰌶 '
            }
        } or {},
        virtual_text = {
            source = 'if_many',
            spacing = 2,
            prefix = '●' -- Or any other prefix you prefer
        }
    })
end

return M
