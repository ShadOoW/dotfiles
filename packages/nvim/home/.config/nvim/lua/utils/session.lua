-- Session utilities for managing Lazy and Mason states
local M = {}

-- Check if Lazy has any pending installations (not updates)
function M.has_pending_lazy_operations()
  local success, result = pcall(function()
    local lazy = require('lazy')
    local plugins = lazy.plugins()

    for _, plugin in pairs(plugins) do
      -- Check if plugin needs to be installed (ignore updates)
      if not plugin._.installed then return true end
    end

    return false
  end)

  return success and result or false
end

-- Check if Mason has any pending tool installations
function M.has_pending_mason_installations()
  local success, result = pcall(function()
    local mason_tool_installer = require('mason-tool-installer')
    local mason_registry = require('mason-registry')

    -- Get the ensure_installed configuration
    local config = mason_tool_installer.get_config()
    if not config or not config.ensure_installed then return false end

    -- Check each tool in ensure_installed
    for _, tool_name in ipairs(config.ensure_installed) do
      if mason_registry.has_package(tool_name) then
        local package = mason_registry.get_package(tool_name)
        if not package:is_installed() then return true end
      end
    end

    return false
  end)

  return success and result or false
end

-- Main function to determine what should be opened after session restore
function M.get_post_session_action()
  if M.has_pending_lazy_operations() then
    return 'lazy'
  elseif M.has_pending_mason_installations() then
    return 'mason'
  else
    return nil
  end
end

return M
