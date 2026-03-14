return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
  config = function()
    local diffview = require('diffview')
    local diffview_config = require('diffview.config')

    diffview.setup({
      diff_binaries = false,
      enhanced_diff_hl = false,
      git_cmd = { 'git' },
      use_icons = true,
      hooks = {
        diff_buf_win_enter = function(bufnr, winid, ctx)
          if ctx.symbol == 'A' then
            vim.opt_local.readonly = true
            vim.opt_local.modifiable = false
          end
        end,
      },
      icons = {
        folder_closed = '󰉋',
        folder_open = '󰉖',
        added = '󰄮',
        modified = '󰷾',
        deleted = '󰍵',
        untracked = '󰛩',
        renamed = '󰁕',
        unmerged = '󰡙',
        type_changed = '󰉖',
        unknown = '󰀊',
      },
      signs = {
        fold_closed = '󰅂',
        fold_open = '󰅀',
        added = '󰄮',
        modified = '󰷾',
        deleted = '󰍵',
      },
      mappings = {
        view = {
          ['q'] = diffview_config.actions.close,
        },
        file_panel = {
          ['q'] = diffview_config.actions.close,
        },
        file_history_panel = {
          ['q'] = diffview_config.actions.close,
        },
      },
    })
  end,
  keys = {
    { '<leader>cd', '<cmd>DiffviewOpen<cr>', desc = 'Diffview open' },
  },
}
