local M = {}

M.opts = {
  depth = 5,
  show_untracked = true,
  relative_paths = true,
  exclude = {
    'node_modules',
    'venv',
    '.venv',
    '__pycache__',
    '.git',
  },
}

local colors = {
  reset = '\33[0m',
  red = '\33[31m',
  green = '\33[32m',
  yellow = '\33[33m',
  blue = '\33[34m',
  magenta = '\33[35m',
  cyan = '\33[36m',
  gray = '\33[90m',
}

local status_map = {
  ['M'] = { symbol = 'M', color = colors.red },
  ['A'] = { symbol = 'A', color = colors.green },
  ['D'] = { symbol = 'D', color = colors.red },
  ['R'] = { symbol = 'R', color = colors.yellow },
  ['C'] = { symbol = 'C', color = colors.yellow },
  ['U'] = { symbol = 'U', color = colors.magenta },
  ['??'] = { symbol = '??', color = colors.gray },
  ['AM'] = { symbol = 'AM', color = colors.yellow },
  ['MM'] = { symbol = 'MM', color = colors.yellow },
}

local function get_status_symbol(status)
  local mapped = status_map[status]
  if mapped then
    return mapped.color .. mapped.symbol .. colors.reset
  end
  return status
end

M.setup = function(user_opts)
  M.opts = vim.tbl_deep_extend('force', M.opts, user_opts or {})
end

M.find_git_repos = function(cwd, max_depth)
  local exclude_parts = {}
  for _, pattern in ipairs(M.opts.exclude) do
    table.insert(exclude_parts, '-not')
    table.insert(exclude_parts, '-path')
    table.insert(exclude_parts, '*/' .. pattern .. '/*')
  end

  local find_cmd = {
    'find',
    cwd,
    '-maxdepth',
    tostring(max_depth),
    '-type',
    'd',
    '-name',
    '.git',
    unpack(exclude_parts),
  }

  local output = vim.fn.systemlist(find_cmd)

  if vim.v.shell_error ~= 0 then
    return {}
  end

  local repos = {}
  for _, line in ipairs(output) do
    if line and line ~= '' then
      local repo_dir = line:gsub('/%.git$', '')
      table.insert(repos, repo_dir)
    end
  end

  return repos
end

M.get_repo_branch = function(repo_path)
  local cmd = { 'git', '-C', repo_path, 'branch', '--show-current' }
  local output = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 or #output == 0 then
    return 'unknown'
  end
  return output[1]
end

M.get_modified_files = function(repo_path)
  local cmd = { 'git', '-C', repo_path, 'status', '--porcelain' }

  if M.opts.show_untracked then
    table.insert(cmd, '-uall')
  end

  local output = vim.fn.systemlist(cmd)

  if vim.v.shell_error ~= 0 then
    return {}
  end

  local files = {}
  for _, line in ipairs(output) do
    if line ~= '' then
      local status = line:sub(1, 2)
      local file_path = line:sub(4)
      table.insert(files, {
        status = status,
        path = file_path,
        repo = repo_path,
      })
    end
  end

  return files
end

M.git_status_multi = function(opts)
  opts = opts or {}
  local cwd = opts.cwd or vim.fn.getcwd()
  local depth = opts.depth or M.opts.depth

  local repos = M.find_git_repos(cwd, depth)

  if #repos == 0 then
    vim.notify('No git repositories found in current directory', vim.log.levels.WARN)
    return
  end

  local all_files = {}
  local repo_branches = {}

  for _, repo in ipairs(repos) do
    repo_branches[repo] = M.get_repo_branch(repo)
  end

  for _, repo in ipairs(repos) do
    local files = M.get_modified_files(repo)
    local repo_basename = vim.fn.fnamemodify(repo, ':t')
    local branch = repo_branches[repo] or 'unknown'

    for _, file in ipairs(files) do
      local display_path
      if M.opts.relative_paths then
        display_path = repo_basename .. '/' .. file.path
      else
        display_path = file.path
      end

      local status_symbol = get_status_symbol(file.status)
      local plain_display = status_symbol .. ' ' .. branch .. ':' .. display_path

      table.insert(all_files, {
        repo = repo,
        file = file.path,
        status = file.status,
        display_plain = plain_display,
        display_stripped = file.status .. ' ' .. branch .. ':' .. display_path,
        full_path = repo .. '/' .. file.path,
      })
    end
  end

  if #all_files == 0 then
    vim.notify('No modified files found in any repository', vim.log.levels.INFO)
    return
  end

  local fzf = require('fzf-lua')

  fzf.git_status({
    prompt = 'Git Status> ',
  })
end

return M
