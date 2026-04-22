local M = {}

M.opts = {
  depth = 5,
}

M.setup = function(user_opts) M.opts = vim.tbl_deep_extend('force', M.opts, user_opts or {}) end

M.git_status_multi = function(opts)
  local fzf = require('fzf-lua')
  fzf.git_status({
    prompt = 'Git Status> ',
    fzf_opts = {
      ['--bind'] = 'ctrl-y:execute-silent(echo {+} | xclip -selection clipboard)',
    },
  })
end

return M
