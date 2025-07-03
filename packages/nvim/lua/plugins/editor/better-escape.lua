-- Better escape plugin - allows escaping insert mode with key combinations like 'jk'
return {
  'max397574/better-escape.nvim',
  event = 'InsertCharPre',
  config = function()
    require('better_escape').setup({
      timeout = 1000, -- the time in which the keys must be hit in ms
      default_mappings = false, -- setting this to false removes all the default mappings
      mappings = {
        -- i for insert mode
        i = {
          q = {
            q = '<Esc>', -- qq to escape insert mode
          },
        },
        -- c for command mode
        c = {
          q = {
            q = '<Esc>',
          },
        },
        -- t for terminal mode
        t = {
          q = {
            q = '<C-\\><C-n>',
          },
        },
        -- v for visual mode
        v = {
          q = {
            q = '<Esc>',
          },
        },
        -- s for select mode
        s = {
          q = {
            q = '<Esc>',
          },
        },
      },
    })
  end,
}
