-- Modern Obsidian utility functions with NUI-based form interface
-- Provides auto-completion and intelligent data extraction for note creation
local M = {}

-- NUI components (only available in Neovim environment)
local Input, Menu, Popup, Layout
if vim and vim.fn then
  local ok1, input = pcall(require, 'nui.input')
  local ok2, menu = pcall(require, 'nui.menu')
  local ok3, popup = pcall(require, 'nui.popup')
  local ok4, layout = pcall(require, 'nui.layout')

  if ok1 and ok2 and ok3 and ok4 then
    Input, Menu, Popup, Layout = input, menu, popup, layout
  end
end

-- Constants
M.WORKSPACE_PATH = '/mnt/share/brain'
M.DAILY_FOLDER = 'daily'
M.BOOKS_FOLDER = '3-resources/books'
M.TEMPLATES_FOLDER = 'templates'

-- Date utilities
M.date = {
  today = function() return os.date('%Y-%m-%d') end,
  yesterday = function() return os.date('%Y-%m-%d', os.time() - 24 * 60 * 60) end,
  tomorrow = function() return os.date('%Y-%m-%d', os.time() + 24 * 60 * 60) end,
  format_id = function() return os.date('%Y%m%d') end,
  offset = function(days) return os.date('%Y-%m-%d', os.time() + (days * 24 * 60 * 60)) end,
}

-- File system utilities
M.fs = {
  ensure_dir = function(path)
    if not vim.fn.isdirectory(path) then vim.fn.mkdir(path, 'p') end
  end,

  sanitize_filename = function(name) return name:gsub('[^%w%s%-]', ''):gsub('%s+', '-'):lower() end,

  get_full_path = function(relative_path) return M.WORKSPACE_PATH .. '/' .. relative_path end,

  scan_books = function()
    local books_path = M.fs.get_full_path(M.BOOKS_FOLDER)
    local books = {}

    -- Use vim.loop if available (Neovim), otherwise use system commands
    if vim and vim.loop then
      local handle = vim.loop.fs_scandir(books_path)

      if handle then
        local name, type = vim.loop.fs_scandir_next(handle)
        while name do
          if type == 'directory' and not name:match('^%.') then table.insert(books, name) end
          name, type = vim.loop.fs_scandir_next(handle)
        end
      end
    else
      -- Fallback for testing outside Neovim
      local cmd = 'find "'
        .. books_path
        .. '" -maxdepth 1 -type d -not -name ".*" -printf "%f\\n" 2>/dev/null | tail -n +2'
      local handle = io.popen(cmd)
      if handle then
        for line in handle:lines() do
          if line and line ~= '' then table.insert(books, line) end
        end
        handle:close()
      end
    end

    table.sort(books)
    return books
  end,

  get_latest_markdown = function(book_folder)
    local book_path = M.fs.get_full_path(M.BOOKS_FOLDER .. '/' .. book_folder)
    local files = {}

    -- Use vim.loop if available (Neovim), otherwise use system commands
    if vim and vim.loop then
      local handle = vim.loop.fs_scandir(book_path)

      if handle then
        local name, type = vim.loop.fs_scandir_next(handle)
        while name do
          if type == 'file' and name:match('%.md$') then
            local full_path = book_path .. '/' .. name
            local stat = vim.loop.fs_stat(full_path)
            if stat then
              table.insert(files, {
                name = name,
                path = full_path,
                mtime = stat.mtime.sec,
              })
            end
          end
          name, type = vim.loop.fs_scandir_next(handle)
        end
      end
    else
      -- Fallback for testing outside Neovim
      local cmd = 'find "'
        .. book_path
        .. '" -maxdepth 1 -name "*.md" -type f -printf "%T@ %p\\n" 2>/dev/null | sort -rn'
      local handle = io.popen(cmd)
      if handle then
        for line in handle:lines() do
          local mtime, path = line:match('^([%d%.]+)%s+(.+)$')
          if mtime and path then
            table.insert(files, {
              name = path:match('([^/]+)$'),
              path = path,
              mtime = tonumber(mtime) or 0,
            })
          end
        end
        handle:close()
      end
    end

    if #files == 0 then return nil end

    -- Sort by modification time, newest first (if not already sorted)
    if vim and vim.loop then table.sort(files, function(a, b) return a.mtime > b.mtime end) end

    return files[1].path
  end,

  parse_frontmatter = function(file_path)
    local file = io.open(file_path, 'r')
    if not file then return {} end

    local content = file:read('*all')
    file:close()

    local frontmatter = {}
    local in_frontmatter = false
    local frontmatter_end = false
    local current_key = nil
    local current_list = {}

    for line in content:gmatch('[^\r\n]+') do
      if line:match('^%-%-%-$') then
        if not in_frontmatter then
          in_frontmatter = true
        else
          -- End of frontmatter - save any pending list
          if current_key and #current_list > 0 then frontmatter[current_key] = current_list end
          frontmatter_end = true
          break
        end
      elseif in_frontmatter and not frontmatter_end then
        -- Check for YAML list item
        local list_item = line:match('^%s*%-%s*(.+)$')
        if list_item and current_key then
          -- This is a list item for the current key
          list_item = list_item:gsub('^["\']', ''):gsub('["\']$', '')
          table.insert(current_list, list_item)
        else
          -- Save previous list if exists
          if current_key and #current_list > 0 then
            frontmatter[current_key] = current_list
            current_list = {}
          end

          -- Parse key-value pair
          local key, value = line:match('^([%w_]+):%s*(.*)$')
          if key then
            if value and value ~= '' then
              -- Clean up value
              value = value:gsub('^["\']', ''):gsub('["\']$', '')
              frontmatter[key] = value
              current_key = nil
            else
              -- This might be the start of a list
              current_key = key
              current_list = {}
            end
          end
        end
      end
    end

    -- Handle any remaining list
    if current_key and #current_list > 0 then frontmatter[current_key] = current_list end

    return frontmatter
  end,
}

-- Template substitution utilities
M.template = {
  get_substitutions = function(note_type, data)
    local base_subs = {
      ['{{today}}'] = M.date.today(),
      ['{{yesterday}}'] = M.date.yesterday(),
      ['{{tomorrow}}'] = M.date.tomorrow(),
      ['{{date:YYYY-MM-DD}}'] = M.date.today(),
      ['{{date:YYYYMMDD}}'] = M.date.format_id(),
      ['{{date:YYYY-MM-DD -1d}}'] = M.date.yesterday(),
      ['{{date:YYYY-MM-DD +1d}}'] = M.date.tomorrow(),
    }

    if note_type == 'book' and data then
      base_subs['{{chapter_title}}'] = data.chapter_title or 'Chapter Title Here'
      base_subs['{{book_title}}'] = data.book_title or 'Book Title Here'

      -- Handle author field - create proper YAML list for all authors
      local author_list = ''
      local authors = {}

      if data.author then
        if type(data.author) == 'table' then
          -- Author is already a list from frontmatter parsing
          for _, author in ipairs(data.author) do
            if author and author ~= '' then table.insert(authors, '  - ' .. author) end
          end
        elseif type(data.author) == 'string' and data.author ~= '' then
          -- Author is a string, split by comma if needed
          if data.author:find(',') then
            for author in data.author:gmatch('([^,]+)') do
              local clean_author = author:gsub('^%s*(.-)%s*$', '%1')
              if clean_author and clean_author ~= '' then table.insert(authors, '  - ' .. clean_author) end
            end
          else
            local clean_author = data.author:gsub('^%s*(.-)%s*$', '%1')
            if clean_author and clean_author ~= '' then table.insert(authors, '  - ' .. clean_author) end
          end
        end
      end

      -- Create YAML list format for author_list
      if #authors > 0 then
        author_list = '\n' .. table.concat(authors, '\n')
      else
        author_list = '\n  - '
      end

      base_subs['{{author_list}}'] = author_list
      base_subs['{{chapter_number}}'] = tostring(tonumber(data.chapter_number) or 1)
      base_subs['{{related_topics}}'] = '[]'

      -- Add ID field for Obsidian compatibility
      local chapter_slug = M.fs.sanitize_filename(data.chapter_title or 'chapter')
      base_subs['{{id}}'] = 'ch' .. tostring(tonumber(data.chapter_number) or 1) .. '-' .. chapter_slug
    end

    return base_subs
  end,

  apply_to_buffer = function(note_type, data)
    local buf = vim.api.nvim_get_current_buf()
    local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
    local modified = false
    local substitutions = M.template.get_substitutions(note_type, data)

    -- Handle special markdown link cases first
    content = content:gsub('%[%[{{yesterday}}%]%]', '[[' .. M.date.yesterday() .. '.md]]')
    content = content:gsub('%[%[{{tomorrow}}%]%]', '[[' .. M.date.tomorrow() .. '.md]]')
    content = content:gsub('%[%[{{today}}%]%]', '[[' .. M.date.today() .. '.md]]')

    -- Apply regular substitutions with proper escaping
    for pattern, replacement in pairs(substitutions) do
      -- Escape the pattern for safe regex matching
      local escaped_pattern = pattern:gsub('([%(%)%[%]%{%}%+%-%*%?%^%$%%])', '%%%1')

      -- Handle the replacement value safely
      local safe_replacement = replacement
      if type(replacement) == 'string' then
        -- Escape special characters in replacement string, but preserve newlines
        safe_replacement = replacement:gsub('%%', '%%%%')
      else
        safe_replacement = tostring(replacement)
      end

      local new_content = content:gsub(escaped_pattern, safe_replacement)
      if new_content ~= content then
        content = new_content
        modified = true
      end
    end

    if modified then
      local new_lines = vim.split(content, '\n', {
        plain = true,
      })
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
      return true
    end
    return false
  end,
}

-- Note path utilities
M.paths = {
  daily_note = function(date)
    date = date or M.date.today()
    return M.DAILY_FOLDER .. '/' .. date .. '.md'
  end,

  book_note = function(book_title, chapter_title, chapter_number)
    local book_slug = M.fs.sanitize_filename(book_title)
    local chapter_slug = M.fs.sanitize_filename(chapter_title)
    local filename = string.format('ch%s-%s', chapter_number, chapter_slug)
    return M.BOOKS_FOLDER .. '/' .. book_slug .. '/' .. filename .. '.md'
  end,

  is_daily_note = function(path)
    if not path or type(path) ~= 'string' then return false end
    return path:match('daily/') ~= nil or path:match('%d%d%d%d%-%d%d%-%d%d%.md$') ~= nil
  end,

  is_book_note = function(path)
    if not path or type(path) ~= 'string' then return false end
    return path:match('books/') ~= nil or path:match('3%-resources/books/') ~= nil
  end,
}

-- Note creation utilities
M.create = {
  daily_note = function(date_offset)
    date_offset = date_offset or 0
    local date = M.date.offset(date_offset)
    local note_path = M.paths.daily_note(date)
    local full_path = M.fs.get_full_path(note_path)

    -- Create directory if needed
    M.fs.ensure_dir(vim.fn.fnamemodify(full_path, ':h'))

    -- Use obsidian commands if available, otherwise create manually
    if date_offset == 0 then
      vim.cmd('silent! ObsidianToday')
    elseif date_offset == -1 then
      vim.cmd('silent! ObsidianYesterday')
    elseif date_offset == 1 then
      vim.cmd('silent! ObsidianTomorrow')
    else
      vim.cmd('edit ' .. vim.fn.fnameescape(full_path))
    end

    return note_path
  end,

  book_note = function(book_data)
    if not book_data or not book_data.book_title or not book_data.chapter_title then
      vim.notify('Missing book data', vim.log.levels.ERROR)
      return nil
    end

    local note_path = M.paths.book_note(book_data.book_title, book_data.chapter_title, book_data.chapter_number or '1')
    local full_path = M.fs.get_full_path(note_path)

    -- Create directory structure (ensure all parent directories exist)
    local dir_path = vim.fn.fnamemodify(full_path, ':h')

    -- Ensure directory exists
    if vim.fn.isdirectory(dir_path) == 0 then
      local result = vim.fn.mkdir(dir_path, 'p')
      if result == 0 then
        vim.notify('Failed to create directory: ' .. dir_path, vim.log.levels.ERROR)
        return nil
      end
      vim.notify('Created directory: ' .. dir_path, vim.log.levels.INFO)
    end

    -- Open the file
    vim.cmd('edit ' .. vim.fn.fnameescape(full_path))

    -- Apply template
    vim.defer_fn(function()
      vim.opt_local.modifiable = true
      vim.cmd('silent! ObsidianTemplate book-chapter-note')

      -- Apply substitutions
      vim.defer_fn(function()
        if M.template.apply_to_buffer('book', book_data) then
          vim.notify('Book chapter note created: ' .. book_data.book_title, vim.log.levels.INFO)
        end
      end, 300)
    end, 100)

    return note_path
  end,
}

-- Modern NUI-based book form with simplified workflows
M.ui = {
  -- Main entry point - shows choice between new book or existing book
  create_book_form = function(callback)
    -- Check if we're in Neovim environment with required components
    if not (vim and vim.fn and Input and Menu and Popup) then
      error('NUI components not available. This function requires Neovim with nui.nvim plugin.')
      return
    end

    -- Get available books
    local books = M.fs.scan_books()

    -- Use fzf-lua for book selection
    if _G.fzf_select_book then
      _G.fzf_select_book(books, callback)
    else
      -- Fallback to NUI menu with new book option
      local menu_items = {}
      for i, book in ipairs(books) do
        table.insert(
          menu_items,
          Menu.item(book, {
            id = i,
          })
        )
      end

      -- Add new book option
      table.insert(menu_items, Menu.separator())
      table.insert(
        menu_items,
        Menu.item('+ New Book...', {
          id = 'new',
        })
      )

      local menu = Menu({
        position = '50%',
        size = {
          width = 60,
          height = math.min(#books + 4, 20),
        },
        relative = 'editor',
        border = {
          style = 'rounded',
          text = {
            top = ' Select or Create Book ',
            top_align = 'center',
          },
        },
        win_options = {
          winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
        },
      }, {
        lines = menu_items,
        keymap = {
          focus_next = { 'j', '<Down>', '<Tab>' },
          focus_prev = { 'k', '<Up>', '<S-Tab>' },
          close = { '<Esc>', '<C-c>' },
          submit = { '<CR>', '<Space>' },
        },
        on_close = function() end,
        on_submit = function(item)
          if item.id == 'new' then
            M.ui.create_new_book(callback)
          else
            M.ui.add_chapter_to_existing_book(item.text, callback)
          end
        end,
      })

      menu:mount()
    end
  end,

  -- Simplified workflow: Create new book (only asks for book title and chapter title)
  create_new_book = function(callback)
    local book_data = {}

    -- Step 1: Get book title
    local book_input
    book_input = Input({
      position = '50%',
      size = {
        width = 60,
      },
      border = {
        style = 'rounded',
        text = {
          top = ' 📚 New Book Title ',
          top_align = 'center',
        },
      },
    }, {
      prompt = '📖 ',
      default_value = '',
      on_close = function() end,
      on_submit = function(book_title)
        if not book_title or book_title:match('^%s*$') then
          vim.notify('❌ Book title is required', vim.log.levels.ERROR)
          return
        end

        book_data.book_title = book_title
        if book_input then book_input:unmount() end

        -- Step 2: Get chapter title
        M.ui._get_chapter_title_for_new_book(book_data, callback)
      end,
    })

    book_input:map('i', '<Esc>', function()
      if book_input then book_input:unmount() end
      vim.notify('📚 Book creation cancelled', vim.log.levels.INFO)
    end)

    book_input:mount()
    vim.schedule(function()
      vim.api.nvim_set_current_win(book_input.winid)
      vim.cmd('startinsert')
    end)
  end,

  -- Simplified workflow: Add chapter to existing book (auto-detects everything)
  add_chapter_to_existing_book = function(book_title, callback)
    -- Auto-detect data from latest note
    local book_data = {
      book_title = book_title,
    }
    local latest_note = M.fs.get_latest_markdown(book_title)

    if latest_note then
      local frontmatter = M.fs.parse_frontmatter(latest_note)
      book_data.author = frontmatter.author -- Keep original format (table or string)
      book_data.chapter_number = (tonumber(frontmatter.chapter) or 0) + 1 -- Store as number
      book_data.part = tonumber(frontmatter.part) or 1 -- Store as number
    else
      book_data.author = nil
      book_data.chapter_number = 1 -- Store as number
      book_data.part = 1 -- Store as number
    end

    -- Only ask for chapter title, everything else is auto-detected
    local chapter_input
    chapter_input = Input({
      position = '50%',
      size = {
        width = 60,
      },
      border = {
        style = 'rounded',
        text = {
          top = ' 📖 Chapter Title for "' .. book_title .. '" ',
          top_align = 'center',
        },
      },
    }, {
      prompt = '📝 ',
      default_value = '',
      on_close = function() end,
      on_submit = function(chapter_title)
        if not chapter_title or chapter_title:match('^%s*$') then
          vim.notify('❌ Chapter title is required', vim.log.levels.ERROR)
          return
        end

        book_data.chapter_title = chapter_title
        if chapter_input then chapter_input:unmount() end

        -- Create note immediately with auto-detected values
        vim.notify('✅ Creating chapter with auto-detected values', vim.log.levels.INFO)
        if callback then callback(book_data) end
      end,
    })

    chapter_input:map('i', '<Esc>', function()
      if chapter_input then chapter_input:unmount() end
      vim.notify('📚 Chapter creation cancelled', vim.log.levels.INFO)
    end)

    chapter_input:mount()
    vim.schedule(function()
      vim.api.nvim_set_current_win(chapter_input.winid)
      vim.cmd('startinsert')
    end)
  end,

  -- Helper function for new book workflow
  _get_chapter_title_for_new_book = function(book_data, callback)
    local chapter_input
    chapter_input = Input({
      position = '50%',
      size = {
        width = 60,
      },
      border = {
        style = 'rounded',
        text = {
          top = ' 📖 First Chapter Title ',
          top_align = 'center',
        },
      },
    }, {
      prompt = '📝 ',
      default_value = '',
      on_close = function() end,
      on_submit = function(chapter_title)
        if not chapter_title or chapter_title:match('^%s*$') then
          vim.notify('❌ Chapter title is required', vim.log.levels.ERROR)
          return
        end

        -- Set defaults for new book
        book_data.chapter_title = chapter_title
        book_data.author = nil
        book_data.chapter_number = 1
        book_data.part = 1

        if chapter_input then chapter_input:unmount() end

        -- Create book folder
        local book_slug = M.fs.sanitize_filename(book_data.book_title)
        local book_path = M.fs.get_full_path(M.BOOKS_FOLDER .. '/' .. book_slug)
        M.fs.ensure_dir(book_path)

        vim.notify('📚 Created new book: ' .. book_data.book_title, vim.log.levels.INFO)

        -- Create the first chapter
        if callback then callback(book_data) end
      end,
    })

    chapter_input:map('i', '<Esc>', function()
      if chapter_input then chapter_input:unmount() end
      vim.notify('📚 Book creation cancelled', vim.log.levels.INFO)
    end)

    chapter_input:mount()
    vim.schedule(function()
      vim.api.nvim_set_current_win(chapter_input.winid)
      vim.cmd('startinsert')
    end)
  end,
}

return M
