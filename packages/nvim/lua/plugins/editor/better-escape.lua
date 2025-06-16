-- Better escape plugin - allows escaping insert mode with key combinations like 'jk'
-- Updated to new configuration format (post-rewrite)
return {
  'max397574/better-escape.nvim',
  event = 'InsertEnter',
  config = function()
    require('better_escape').setup({
      timeout = 120, -- the time in which the keys must be hit in ms
      default_mappings = true, -- setting this to false removes all the default mappings
      mappings = {
        -- i for insert mode
        i = {
          j = {
            k = '<Esc>', -- jk to escape insert mode
            j = '<Esc>', -- jj to escape insert mode
          },
          a = {
            s = {
              d = function()
                -- Clear line after escaping if there is only whitespace (like old clear_empty_lines)
                vim.api.nvim_input('<Esc>')
                local current_line = vim.api.nvim_get_current_line()
                if current_line:match('^%s+$') then vim.schedule(function() vim.api.nvim_set_current_line('') end) end
              end,
            },
          },
        },
        -- c for command mode
        c = {
          j = {
            k = '<Esc>',
            j = '<Esc>',
          },
        },
        -- t for terminal mode
        t = {
          j = {
            k = '<C-\\><C-n>',
          },
        },
        -- v for visual mode
        v = {
          j = {
            k = '<Esc>',
          },
        },
        -- s for select mode
        s = {
          j = {
            k = '<Esc>',
          },
        },
      },
    })
  end,
}
