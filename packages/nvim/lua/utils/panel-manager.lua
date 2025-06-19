-- Simple Panel Manager for Exclusive Panel Management
-- Ensures only one panel from a group is open at a time
local M = {}

-- Active panel tracking
local _active_panels = {}

--- Create an exclusive panel manager for a group of panels
--- @param group_name string Unique identifier for the panel group
--- @param panel_configs table Configuration for each panel in the group
--- @return table Panel manager functions
function M.create_exclusive_group(group_name, panel_configs)
  if not _active_panels[group_name] then
    _active_panels[group_name] = {
      current = nil,
      configs = panel_configs or {},
    }
  end

  local group = _active_panels[group_name]

  --- Open a panel exclusively (closes others in the same group)
  --- @param panel_id string The panel identifier
  --- @param opts table? Optional configuration for opening the panel
  local function open_exclusive(panel_id, opts)
    local config = group.configs[panel_id]
    if not config then
      vim.notify('Panel ' .. panel_id .. ' not found in group ' .. group_name, vim.log.levels.WARN)
      return false
    end

    -- If this panel is already active, toggle it off
    if group.current == panel_id then
      if config.is_open and config.is_open() then
        if config.close then config.close() end
        group.current = nil
        if config.global_var then _G[config.global_var] = nil end
        if config.refresh_cmd then vim.schedule(function() vim.cmd(config.refresh_cmd) end) end
        return true
      end
    end

    -- Close currently active panel if different
    if group.current and group.current ~= panel_id then
      local current_config = group.configs[group.current]
      if current_config and current_config.is_open and current_config.is_open() then
        if current_config.close then current_config.close() end
      end
    end

    -- Set as current panel
    group.current = panel_id

    -- Open the panel (prefer open over toggle for switching between panels)
    local success = false
    if config.open then
      success = config.open(opts)
    elseif config.toggle then
      success = config.toggle(opts)
    end

    -- Check if panel is actually open
    if config.is_open and not config.is_open() then group.current = nil end

    -- Update global state if configured
    if config.global_var then _G[config.global_var] = group.current end

    -- Refresh UI if configured
    if config.refresh_cmd then vim.schedule(function() vim.cmd(config.refresh_cmd) end) end

    return success
  end

  --- Close the currently active panel in this group
  local function close_current()
    if not group.current then return true end

    local config = group.configs[group.current]
    if config and config.close then config.close() end

    group.current = nil
    if config and config.global_var then _G[config.global_var] = nil end

    if config and config.refresh_cmd then vim.schedule(function() vim.cmd(config.refresh_cmd) end) end

    return true
  end

  --- Get the currently active panel
  local function get_current() return group.current end

  --- Check if a specific panel is currently active
  local function is_active(panel_id) return group.current == panel_id end

  --- Create a keymap function for a specific panel
  local function create_keymap(panel_id, opts)
    return function() open_exclusive(panel_id, opts) end
  end

  return {
    open = open_exclusive,
    close = close_current,
    current = get_current,
    is_active = is_active,
    keymap = create_keymap,
  }
end

--- Setup autocmd to clean up panel state when windows close
function M.setup_cleanup()
  vim.api.nvim_create_autocmd('BufWinLeave', {
    pattern = '*',
    callback = function()
      -- Clean up any groups that no longer have active panels
      for group_name, group in pairs(_active_panels) do
        if group.current then
          local config = group.configs[group.current]
          if config and config.is_open and not config.is_open() then
            group.current = nil
            if config.global_var then _G[config.global_var] = nil end
          end
        end
      end
    end,
    desc = 'Clean up panel manager state when windows close',
  })

  -- Set filetype for exclusive panels to ensure they're excluded from sessions
  vim.api.nvim_create_autocmd('BufWinEnter', {
    pattern = '*',
    callback = function(args)
      local buf = args.buf
      if not vim.api.nvim_buf_is_valid(buf) then return end

      local bufname = vim.api.nvim_buf_get_name(buf)
      local buftype = vim.api.nvim_get_option_value('buftype', {
        buf = buf,
      })

      -- Check if this looks like a trouble panel or other exclusive panel
      if
        bufname:match('trouble://')
        or (
          buftype == 'nofile'
          and vim.api.nvim_get_option_value('filetype', {
            buf = buf,
          }) == 'trouble'
        )
      then
        -- Set a specific filetype to ensure session exclusion
        vim.api.nvim_set_option_value('filetype', 'exclusive-panel', {
          buf = buf,
        })
      end
    end,
    desc = 'Mark exclusive panels with special filetype for session exclusion',
  })
end

-- Expose internal state for session cleanup
M._active_panels = _active_panels

-- Automatically setup cleanup when the module is loaded
M.setup_cleanup()

return M
