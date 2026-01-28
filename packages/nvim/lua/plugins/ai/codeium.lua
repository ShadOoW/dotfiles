-- Codeium AI completion - FREE with generous limits
return {
  'Exafunction/codeium.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'hrsh7th/nvim-cmp' },
  event = 'InsertEnter',
  build = ':Codeium Auth',
  config = function()
    require('codeium').setup({
      enable_cmp_source = false,
      virtual_text = {
        enabled = true,
        manual = false,
        default_filetype_enabled = true,
        idle_delay = 150,
        virtual_text_priority = 200,
        map_keys = true,
        key_bindings = {
          -- Tab accepts AI suggestion; keep others non-intrusive
          accept = '<Tab>',
          accept_word = '<C-M-CR>',
          accept_line = '<M-\\>',
          clear = '<C-BS>',
          next = '<M-]>',
          prev = '<M-[>',
        },
      },
    })

    -- Improve Codeium ghost text visibility
    pcall(vim.api.nvim_set_hl, 0, 'CodeiumSuggestion', {
      fg = '#7aa2f7',
      italic = true,
      nocombine = true,
    })
    pcall(vim.api.nvim_set_hl, 0, 'CodeiumVirtualText', {
      fg = '#7aa2f7',
      italic = true,
      nocombine = true,
    })
  end,
}
