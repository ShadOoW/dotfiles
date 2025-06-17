-- Snippet configuration
local M = {}

function M.setup()
  -- Check if luasnip is available
  local ok, luasnip = pcall(require, 'luasnip')
  if not ok then return end

  -- Set LuaSnip configuration
  luasnip.config.set_config({
    history = true,
    updateevents = 'TextChanged,TextChangedI',
    enable_autosnippets = true,
    ext_opts = {
      [require('luasnip.util.types').choiceNode] = {
        active = {
          virt_text = { { '●', 'Orange' } },
        },
      },
    },
  })

  -- Load VS Code style snippets from friendly-snippets
  require('luasnip.loaders.from_vscode').lazy_load()

  -- Key mappings for snippet navigation
  vim.keymap.set({ 'i', 's' }, '<C-l>', function()
    if luasnip.choice_active() then luasnip.change_choice(1) end
  end, {
    desc = 'Change snippet choice',
  })

  vim.keymap.set({ 'i', 's' }, '<C-h>', function()
    if luasnip.choice_active() then luasnip.change_choice(-1) end
  end, {
    desc = 'Previous snippet choice',
  })
end

return M
