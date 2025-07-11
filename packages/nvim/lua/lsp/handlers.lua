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
      desc = 'LSP: ' .. desc,
    })
  end

  -- Inlay hints toggle (if supported)
  if client.server_capabilities.inlayHintProvider then
    -- Enable inlay hints by default
    vim.lsp.inlay_hint.enable(true, {
      bufnr = bufnr,
    })

    buf_map(
      'n',
      '<leader>th',
      function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({
          bufnr = bufnr,
        }))
      end,
      '[T]oggle Inlay [H]ints'
    )
  end

  -- Document highlight with better error handling
  if client.server_capabilities.documentHighlightProvider == true then
    local highlight_group = vim.api.nvim_create_augroup('lsp-document-highlight-' .. bufnr, {
      clear = true,
    })

    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = bufnr,
      group = highlight_group,
      callback = function() pcall(vim.lsp.buf.document_highlight) end,
      desc = 'Document highlight on cursor hold',
    })

    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = bufnr,
      group = highlight_group,
      callback = function() pcall(vim.lsp.buf.clear_references) end,
      desc = 'Clear document highlight on cursor move',
    })
  end
end

-- Configure diagnostics
function M.setup_diagnostics()
  vim.diagnostic.config({
    severity_sort = true,
    float = {
      border = 'rounded',
      source = 'if_many',
    },
    underline = {
      severity = vim.diagnostic.severity.ERROR,
    },
    signs = vim.g.have_nerd_font and {
      text = {
        [vim.diagnostic.severity.ERROR] = '󰅚 ',
        [vim.diagnostic.severity.WARN] = '󰀪 ',
        [vim.diagnostic.severity.INFO] = '󰋽 ',
        [vim.diagnostic.severity.HINT] = '󰌶 ',
      },
    } or {},
    virtual_text = {
      source = 'if_many',
      spacing = 2,
      prefix = '●', -- Or any other prefix you prefer
    },
  })
end

return M
