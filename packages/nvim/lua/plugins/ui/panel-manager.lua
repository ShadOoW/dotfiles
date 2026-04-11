-- panel-manager.lua: Centralized bottom panel coordination
-- Ensures only one panel is open at a time
local M = {
  panels = {},
}

-- Set while panel_manager itself is opening a panel, to skip the BufWinEnter autocmd
local _opening = nil

function M.register(config)
  M.panels[config.ft] = {
    open = config.open,
    close = config.close,
    is_open = config.is_open,
    title = config.title or config.ft,
    -- If true, the panel takes focus when opened (e.g. terminal)
    -- If false (default), focus returns to the previous window after opening
    focus_panel = config.focus_panel or false,
  }
end

local function close_others(except_ft)
  for ft, panel in pairs(M.panels) do
    if ft ~= except_ft then pcall(panel.close) end
  end
end

-- Open a panel (closes all others first)
-- By default restores focus to the calling window; set focus_panel=true in
-- the registration to let the panel keep focus (e.g. terminal).
function M.open(ft)
  local panel = M.panels[ft]
  if not panel then return end

  local prev_win = vim.api.nvim_get_current_win()
  _opening = ft
  close_others(ft)
  pcall(panel.open)
  _opening = nil

  if not panel.focus_panel then
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(prev_win) then vim.api.nvim_set_current_win(prev_win) end
    end)
  end
end

-- Like open(), but uses a custom open function instead of the registered one.
-- Useful for panels with multiple modes (e.g. trouble: diagnostics, loclist, …)
function M.open_with(ft, open_fn)
  local panel = M.panels[ft]
  if not panel then return end

  local prev_win = vim.api.nvim_get_current_win()
  _opening = ft
  close_others(ft)
  pcall(open_fn)
  _opening = nil

  if not panel.focus_panel then
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(prev_win) then vim.api.nvim_set_current_win(prev_win) end
    end)
  end
end

-- Toggle a panel
function M.toggle(ft)
  local panel = M.panels[ft]
  if not panel then return end

  local ok, is_open = pcall(panel.is_open)
  if ok and is_open then
    pcall(panel.close)
  else
    M.open(ft)
  end
end

function M.close_all()
  for _, panel in pairs(M.panels) do
    pcall(panel.close)
  end
end

-- Call once after all panels are registered.
-- Intercepts auto-opens (e.g. noice opening on notification) via BufWinEnter.
function M.setup()
  local group = vim.api.nvim_create_augroup('PanelManager', { clear = true })

  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = group,
    callback = function(args)
      local buf = args.buf
      if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
      local ft = vim.bo[buf].filetype
      if not M.panels[ft] then return end
      -- We triggered this open ourselves; close_others already ran
      if _opening == ft then return end

      -- Confirm the buffer is in a non-floating split (not a popup)
      local in_split = false
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then
          local wcfg = vim.api.nvim_win_get_config(win)
          if wcfg.relative == '' then
            in_split = true
            break
          end
        end
      end
      if not in_split then return end

      -- Panel appeared on its own (auto-open) — close any competing panels
      close_others(ft)
    end,
  })
end

return M
