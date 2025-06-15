local M = {}

-- Debug function for treesitter syntax tree analysis
function M.DebugTreesitter()
  local ts_utils = require('nvim-treesitter.ts_utils')
  local cursor_node = ts_utils.get_node_at_cursor()

  if not cursor_node then
    print('No treesitter node found at cursor')
    return
  end

  print('=== TREESITTER DEBUG INFO ===')
  print('Current node type: ' .. cursor_node:type())

  local node_text = vim.treesitter.get_node_text(cursor_node, 0)
  if #node_text < 100 then
    print('Current node text: ' .. node_text)
  else
    print('Current node text: [too long to display]')
  end

  -- Show parent hierarchy
  print('--- PARENT HIERARCHY ---')
  local node = cursor_node
  local level = 0
  while node do
    local indent = string.rep('  ', level)
    print(string.format('%s%d: %s', indent, level, node:type()))
    node = node:parent()
    level = level + 1
    if level > 10 then break end -- Prevent infinite loops
  end

  -- Show siblings
  print('--- SIBLINGS ---')
  local parent = cursor_node:parent()
  if parent then
    for i = 0, parent:child_count() - 1 do
      local child = parent:child(i)
      if child then
        local marker = child == cursor_node and ' <-- CURRENT' or ''
        print(string.format('%d: %s%s', i, child:type(), marker))
        if child:type() ~= ',' and child:type() ~= '{' and child:type() ~= '}' then
          local text = vim.treesitter.get_node_text(child, 0)
          if #text < 50 then print(string.format('   Text: "%s"', text)) end
        end
      end
    end
  end

  -- Show parser info
  print('--- PARSER INFO ---')
  local parser = vim.treesitter.get_parser(0)
  if parser then
    local lang = parser:lang()
    print('Java parser available: ' .. tostring(lang == 'java'))
  else
    print('No parser available')
  end
  print('Current filetype: ' .. vim.bo.filetype)

  -- Test text objects
  local ts_swap = require('nvim-treesitter.textobjects.swap')
  print('\n--- TESTING TEXT OBJECTS ---')
  local test_objects = {
    '@parameter.inner',
    '@parameter.outer',
    '@argument.inner',
    '@argument.outer',
    '@statement.outer',
    '@assignment.outer',
    '@field.outer',
    '@variable.outer',
    '@declaration.outer',
    '@expression.outer',
  }

  for _, obj in ipairs(test_objects) do
    local available = ts_swap.swap_next(obj, true) -- dry run
    print(obj .. ': ' .. (available and 'Available' or 'Not available'))
  end
end

-- Debug command for Java treesitter testing
function M.DebugTestJava()
  local ts_utils = require('nvim-treesitter.ts_utils')

  if vim.bo.filetype ~= 'java' then
    vim.notify('Current buffer is not a Java file (filetype: ' .. vim.bo.filetype .. ')', vim.log.levels.WARN)
    return
  end

  local cursor_node = ts_utils.get_node_at_cursor()
  if cursor_node then
    vim.notify('Java treesitter working! Current node: ' .. cursor_node:type(), vim.log.levels.INFO)
  else
    vim.notify('Java treesitter not working - no node found', vim.log.levels.ERROR)
  end
end

-- Setup debug keymaps
function M.setup()
  -- Create user commands for debug functions
  vim.api.nvim_create_user_command('DebugTreesitter', M.DebugTreesitter, {
    desc = 'Debug treesitter syntax tree',
  })

  vim.api.nvim_create_user_command('DebugTestJava', M.DebugTestJava, {
    desc = 'Test Java treesitter functionality',
  })
end

return M
