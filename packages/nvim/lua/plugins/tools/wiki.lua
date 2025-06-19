-- Wiki.vim: Personal wiki system with markdown and journaling
return {
  {
    'lervag/wiki.vim',
    config = function()
      local notify = require('utils.notify')

      -- Wiki configuration
      vim.g.wiki_root = '/mnt/share/wiki'
      vim.g.wiki_filetypes = { 'md' }
      vim.g.wiki_link_extension = '.md'
      vim.g.wiki_link_target_type = 'md'

      -- Use markdown syntax
      vim.g.wiki_write_on_nav = 1
      vim.g.wiki_completion_enabled = 1
      vim.g.wiki_completion_case_sensitive = 0

      -- Ensure directories exist before wiki tries to access them
      pcall(vim.fn.mkdir, '/mnt/share/wiki/diary', 'p')
      pcall(vim.fn.mkdir, '/mnt/share/wiki/projects', 'p')
      pcall(vim.fn.mkdir, '/mnt/share/wiki/notes', 'p')

      -- Link formatting
      vim.g.wiki_link_creation = {
        md = {
          link_type = 'md',
          url_extension = '.md',
          url_transform = function(text)
            -- Keep the text as-is for relative path creation
            return text
          end,
        },
        ['_'] = {
          link_type = 'md',
          url_extension = '.md',
          url_transform = function(text)
            -- Keep the text as-is for relative path creation
            return text
          end,
        },
      }

      -- Template configuration
      vim.g.wiki_templates = {
        {
          match_re = '^diary/',
          source_filename = '/mnt/share/wiki/templates/diary.md',
        },
        {
          match_re = '^projects/',
          source_filename = '/mnt/share/wiki/templates/project.md',
        },
        {
          match_re = '^notes/',
          source_filename = '/mnt/share/wiki/templates/note.md',
        },
      }

      -- Journal configuration
      vim.g.wiki_journal = {
        name = 'diary',
        root = '', -- Use wiki root directory
        frequency = 'daily',
        date_format = {
          daily = '%Y-%m-%d',
          weekly = '%Y-w%V',
          monthly = '%Y-%m',
        },
      }

      -- Wiki mappings under <leader>W
      local function wiki_keymap(key, cmd, desc)
        vim.keymap.set('n', '<leader>a' .. key, cmd, {
          desc = desc,
          silent = true,
        })
      end

      -- Main wiki navigation
      wiki_keymap('i', '<cmd>WikiIndex<CR>', 'Open Wiki Index')
      wiki_keymap('o', '<cmd>WikiOpen<CR>', 'Open Wiki Page')
      wiki_keymap('n', '<cmd>WikiNew<CR>', 'New Wiki Page')
      wiki_keymap('R', '<cmd>WikiReload<CR>', 'Reload Wiki')

      -- Journal/Diary entries (using WikiOpen with specific paths)
      wiki_keymap('d', '<cmd>WikiJournalIndex<CR>', 'Journal Index')
      wiki_keymap('j', function()
        local today = os.date('%Y-%m-%d')
        vim.cmd('WikiOpen diary/' .. today)
      end, 'Today\'s Journal')
      wiki_keymap('y', function()
        local yesterday = os.date('%Y-%m-%d', os.time() - 24 * 60 * 60)
        vim.cmd('WikiOpen diary/' .. yesterday)
      end, 'Yesterday\'s Journal')
      wiki_keymap('t', function()
        local tomorrow = os.date('%Y-%m-%d', os.time() + 24 * 60 * 60)
        vim.cmd('WikiOpen diary/' .. tomorrow)
      end, 'Tomorrow\'s Journal')

      -- Use WikiJournalCopyToNext if available, otherwise fallback
      wiki_keymap('c', function()
        local success = pcall(vim.cmd, 'WikiJournalCopyToNext')
        if not success then notify.warn('Wiki', 'WikiJournalCopyToNext not available in current buffer') end
      end, 'Copy to Next Journal')

      -- Search and navigation (use fallbacks for missing commands)
      wiki_keymap('s', function()
        local success = pcall(vim.cmd, 'WikiFzfPages')
        if not success then vim.cmd('WikiPages') end
      end, 'Search Wiki Pages')

      wiki_keymap('g', function()
        local success = pcall(vim.cmd, 'WikiFzfTags')
        if not success then vim.cmd('WikiTags') end
      end, 'Search Wiki Tags')

      wiki_keymap('l', function()
        local success = pcall(vim.cmd, 'WikiFzfToc')
        if not success then notify.info('Wiki', 'Table of Contents not available') end
      end, 'Table of Contents')

      -- Page management (use available commands)
      wiki_keymap('D', function()
        -- Get the current file path
        local current_file = vim.api.nvim_buf_get_name(0)

        -- Check if it's a wiki file
        if not current_file:match('/mnt/share/wiki/') then
          notify.warn('Wiki', 'Not a wiki file')
          return
        end

        -- Check if file exists
        if vim.fn.filereadable(current_file) == 0 then
          notify.warn('Wiki', 'File does not exist')
          return
        end

        -- Confirm deletion (single confirmation)
        local filename = vim.fn.fnamemodify(current_file, ':t')
        local confirm = vim.fn.confirm('Delete wiki file "' .. filename .. '"?', '&Yes\n&No', 2)

        if confirm == 1 then
          -- Delete the file directly to avoid duplicate confirmations
          local delete_success = vim.fn.delete(current_file)
          if delete_success == 0 then
            -- Close the buffer and switch to previous buffer
            vim.cmd('bprevious')
            vim.cmd('bdelete! ' .. vim.fn.bufnr(current_file))
            notify.success('Wiki', 'File deleted: ' .. filename)

            -- Regenerate summary since file was deleted
            vim.schedule(function() vim.cmd('WikiSummary') end)
          else
            notify.error('Wiki', 'Failed to delete file: ' .. filename)
          end
        end
      end, 'Delete Page')

      wiki_keymap('r', function()
        local success = pcall(vim.cmd, 'WikiPageRename')
        if not success then notify.warn('Wiki', 'WikiPageRename not available in current buffer') end
      end, 'Rename Page')

      wiki_keymap('T', function()
        local success = pcall(vim.cmd, 'WikiTagList')
        if not success then vim.cmd('WikiTags') end
      end, 'List Tags')

      wiki_keymap('G', function()
        local success = pcall(vim.cmd, 'WikiGraphFindBacklinks')
        if not success then notify.info('Wiki', 'Backlinks not available') end
      end, 'Find Backlinks')

      -- Export and utilities (use fallbacks)
      wiki_keymap('e', function()
        local success = pcall(vim.cmd, 'WikiExport')
        if not success then notify.info('Wiki', 'WikiExport not available') end
      end, 'Export Wiki')

      wiki_keymap('E', function()
        local success = pcall(vim.cmd, 'WikiExportTOC')
        if not success then notify.info('Wiki', 'WikiExportTOC not available') end
      end, 'Export TOC')

      wiki_keymap('f', function()
        local success = pcall(vim.cmd, 'WikiFzfFiles')
        if not success then vim.cmd('WikiPages') end
      end, 'Find Files')

      -- Quick templates (fixed to use WikiOpen)
      wiki_keymap('P', function()
        vim.cmd('redraw') -- Clear any messages
        local input = vim.fn.input('Project name: ')
        vim.cmd('redraw') -- Clear input line
        if input and input ~= '' then
          -- Sanitize input (remove invalid characters)
          input = input:gsub('[^%w%s%-_]', ''):gsub('%s+', '-'):lower()
          if input ~= '' then vim.cmd('WikiOpen projects/' .. input) end
        end
      end, 'New Project Page')

      wiki_keymap('N', function()
        vim.cmd('redraw') -- Clear any messages
        local input = vim.fn.input('Note title: ')
        vim.cmd('redraw') -- Clear input line
        if input and input ~= '' then
          -- Sanitize input (remove invalid characters)
          input = input:gsub('[^%w%s%-_]', ''):gsub('%s+', '-'):lower()
          if input ~= '' then vim.cmd('WikiOpen notes/' .. input) end
        end
      end, 'New Note Page')

      -- Custom functions for enhanced workflow
      local function create_wiki_structure()
        local wiki_dirs = {
          '/mnt/share/wiki/diary',
          '/mnt/share/wiki/projects',
          '/mnt/share/wiki/notes',
          '/mnt/share/wiki/templates',
          '/mnt/share/wiki/assets',
        }

        -- Create directories with error handling
        for _, dir in ipairs(wiki_dirs) do
          local success = pcall(vim.fn.mkdir, dir, 'p')
          if not success then notify.warn('Wiki', 'Failed to create directory: ' .. dir) end
        end

        -- Create template files if they don't exist
        local templates = {
          {
            path = '/mnt/share/wiki/templates/diary.md',
            content = [[# Diary Entry - {{date}}

## Today's Goals
- [ ] 

## What Happened
- 

## Thoughts & Reflections
- 

## Tomorrow's Focus
- [ ] 

---
Tags: #diary #{{date}}
]],
          },
          {
            path = '/mnt/share/wiki/templates/project.md',
            content = [[# {{title}}

## Overview
Brief description of the project.

## Goals
- [ ] 
- [ ] 

## Progress
### {{date}}
- Started project

## Resources
- 

## Notes
- 

---
Tags: #project #{{title}}
Status: planning
]],
          },
          {
            path = '/mnt/share/wiki/templates/note.md',
            content = [[# {{title}}

## Summary
Brief summary of the note.

## Content
Main content goes here.

## References
- 

## Related
- 

---
Tags: #note #{{title}}
Created: {{date}}
]],
          },
          {
            path = '/mnt/share/wiki/index.md',
            content = [[# Personal Wiki

Welcome to your personal wiki!

## Quick Navigation
- [Daily Journal](diary/index.md)
- [Projects](projects/index.md)
- [Notes](notes/index.md)

## Recent Entries
<!-- Recent entries will be listed here -->

## Tags
<!-- Common tags will be listed here -->

---
Last updated: {{date}}
]],
          },
        }

        for _, template in ipairs(templates) do
          if vim.fn.filereadable(template.path) == 0 then
            local file = io.open(template.path, 'w')
            if file then
              file:write(template.content)
              file:close()
            end
          end
        end

        print('Wiki structure created at /mnt/share/wiki')
      end

      -- Initialize wiki structure
      wiki_keymap('I', create_wiki_structure, 'Initialize Wiki Structure')

      -- Manual build commands
      wiki_keymap('b', '<cmd>WikiBuild<CR>', 'Build Wiki (mdbook)')
      wiki_keymap('B', '<cmd>WikiClean<CR>', 'Clean Wiki Build')
      wiki_keymap('S', '<cmd>WikiSummary<CR>', 'Generate Summary')

      -- Checkbox and list management
      wiki_keymap('x', function() vim.cmd('MkdnToggleToDo') end, 'Toggle Checkbox')

      wiki_keymap('X', function()
        -- Toggle all checkboxes in current file
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local modified = false
        for i, line in ipairs(lines) do
          local new_line = line
          if line:match('%- %[ %]') then
            new_line = line:gsub('%- %[ %]', '- [x]')
            modified = true
          elseif line:match('%- %[x%]') then
            new_line = line:gsub('%- %[x%]', '- [ ]')
            modified = true
          elseif line:match('%- %[X%]') then
            new_line = line:gsub('%- %[X%]', '- [ ]')
            modified = true
          end
          if new_line ~= line then vim.api.nvim_buf_set_lines(0, i - 1, i, false, { new_line }) end
        end
        if modified then
          notify.success('Wiki', 'Toggled all checkboxes in file')
        else
          notify.warn('Wiki', 'No checkboxes found to toggle')
        end
      end, 'Toggle All Checkboxes')

      -- Wiki-specific autocmds
      local wiki_group = vim.api.nvim_create_augroup('WikiConfig', {
        clear = true,
      })

      -- Auto-save wiki files
      vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost' }, {
        group = wiki_group,
        pattern = '/mnt/share/wiki/*.md',
        callback = function()
          if vim.bo.modified then vim.cmd('silent! write') end
        end,
        desc = 'Auto-save wiki files',
      })

      -- Set wiki-specific options
      vim.api.nvim_create_autocmd('BufEnter', {
        group = wiki_group,
        pattern = '/mnt/share/wiki/*.md',
        callback = function()
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.conceallevel = 2
          vim.opt_local.concealcursor = ''
          vim.opt_local.spell = true

          -- Wiki-specific keybindings
          local opts = {
            buffer = true,
            silent = true,
          }

          -- Use Enter to follow links and Backspace to go back
          vim.keymap.set(
            'n',
            '<CR>',
            function()
              local success = pcall(vim.cmd, 'MkdnFollowLink')
              if not success then
                -- Fallback to normal Enter behavior
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
              end
            end,
            vim.tbl_extend('force', opts, {
              desc = 'Follow wiki link',
            })
          )

          -- Checkbox toggling
          vim.keymap.set(
            { 'n', 'v' },
            '<C-Space>',
            function()
              local success = pcall(vim.cmd, 'MkdnToggleToDo')
              if not success then notify.warn('Wiki', 'Checkbox toggle not available') end
            end,
            vim.tbl_extend('force', opts, {
              desc = 'Toggle checkbox',
            })
          )

          -- Alternative checkbox toggle for terminals that don't support Ctrl+Space
          vim.keymap.set(
            { 'n', 'v' },
            '<leader>x',
            function()
              local success = pcall(vim.cmd, 'MkdnToggleToDo')
              if not success then notify.warn('Wiki', 'Checkbox toggle not available') end
            end,
            vim.tbl_extend('force', opts, {
              desc = 'Toggle checkbox (alt)',
            })
          )

          -- Better list handling
          vim.keymap.set(
            'i',
            '<CR>',
            function()
              local cmp = require('cmp')
              if cmp.visible() then
                return cmp.confirm({
                  behavior = cmp.ConfirmBehavior.Replace,
                  select = false,
                })
              else
                -- Check if we're in a list and handle accordingly
                local line = vim.api.nvim_get_current_line()
                local col = vim.api.nvim_win_get_cursor(0)[2]
                local before_cursor = line:sub(1, col)

                -- Handle checkbox lists
                if before_cursor:match('%s*%- %[.%]') then
                  return vim.api.nvim_feedkeys(
                    vim.api.nvim_replace_termcodes('<CR>- [ ] ', true, false, true),
                    'n',
                    false
                  )
                -- Handle regular lists
                elseif before_cursor:match('%s*%- ') then
                  return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>- ', true, false, true), 'n', false)
                -- Handle numbered lists
                elseif before_cursor:match('%s*%d+%. ') then
                  local num = before_cursor:match('%s*(%d+)%. ')
                  local next_num = tonumber(num) + 1
                  return vim.api.nvim_feedkeys(
                    vim.api.nvim_replace_termcodes('<CR>' .. next_num .. '. ', true, false, true),
                    'n',
                    false
                  )
                else
                  return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
                end
              end
            end,
            vim.tbl_extend('force', opts, {
              desc = 'Smart enter for lists and completion',
            })
          )
        end,
        desc = 'Set wiki-specific options and keybindings',
      })

      -- Additional autocmd to handle wiki buffer initialization safely
      vim.api.nvim_create_autocmd('BufNewFile', {
        group = wiki_group,
        pattern = '/mnt/share/wiki/*.md',
        callback = function()
          -- Ensure the directory exists for the new file
          local file_path = vim.fn.expand('<afile>')
          local dir_path = vim.fn.fnamemodify(file_path, ':h')
          pcall(vim.fn.mkdir, dir_path, 'p')
        end,
        desc = 'Ensure wiki directories exist for new files',
      })
    end,
  },
  {
    'jakewvincent/mkdnflow.nvim',
    ft = 'markdown',
    dependencies = { 'lervag/wiki.vim' },
    config = function()
      require('mkdnflow').setup({
        modules = {
          bib = true,
          buffers = true,
          conceal = true,
          cursor = true,
          folds = false,
          links = true,
          lists = true,
          maps = true,
          paths = true,
          tables = true,
          yaml = false,
        },
        filetypes = {
          md = true,
          rmd = true,
          markdown = true,
        },
        create_dirs = true,
        perspective = {
          priority = 'current',
          fallback = 'current',
          root_tell = false,
          nvim_wd_heel = false,
          update = false,
        },
        wrap = false,
        bib = {
          default_path = nil,
          find_in_root = true,
        },
        silent = false,
        links = {
          style = 'markdown',
          name_is_source = false,
          conceal = false,
          context = 0,
          implicit_extension = nil,
          transform_implicit = false,
          transform_explicit = function(text)
            text = text:gsub(' ', '-')
            text = text:lower()
            return text
          end,
        },
        new_file_template = {
          use_template = false,
          placeholders = {
            before = {
              title = 'link_title',
              date = 'os_date',
            },
            after = {},
          },
          template = '# {{ title }}',
        },
        to_do = {
          symbols = { ' ', '-', 'X' },
          update_parents = true,
          not_started = ' ',
          in_progress = '-',
          complete = 'X',
        },
        tables = {
          trim_whitespace = true,
          format_on_move = true,
          auto_extend_rows = false,
          auto_extend_cols = false,
        },
        yaml = {
          bib = {
            override = false,
          },
        },
        mappings = {
          MkdnEnter = { { 'n', 'v' }, '<CR>' },
          MkdnTab = false,
          MkdnSTab = false,
          MkdnNextLink = { 'n', '<C-]>' },
          MkdnPrevLink = { 'n', '<C-[>' },
          MkdnNextHeading = { 'n', ']]' },
          MkdnPrevHeading = { 'n', '[[' },
          MkdnGoBack = { 'n', '<BS>' },
          MkdnGoForward = { 'n', '<Del>' },
          MkdnCreateLink = false, -- Disable to use wiki.vim for link creation
          MkdnCreateLinkFromClipboard = { { 'n', 'v' }, '<leader>p' },
          MkdnFollowLink = false, -- Disable to use wiki.vim for following links
          MkdnDestroyLink = { 'n', '<M-CR>' },
          MkdnTagSpan = { 'v', '<M-CR>' },
          MkdnMoveSource = { 'n', '<F2>' },
          MkdnYankAnchorLink = { 'n', 'yaa' },
          MkdnYankFileAnchorLink = { 'n', 'yaf' },
          MkdnIncreaseHeading = { 'n', '+' },
          MkdnDecreaseHeading = { 'n', '-' },
          MkdnToggleToDo = { { 'n', 'v' }, '<C-Space>' },
          MkdnNewListItem = false,
          MkdnNewListItemBelowInsert = { 'n', 'o' },
          MkdnNewListItemAboveInsert = { 'n', 'O' },
          MkdnExtendList = false,
          MkdnUpdateNumbering = { 'n', '<leader>nn' },
          MkdnTableNextCell = false, -- Disabled to allow Codeium tab acceptance
          MkdnTablePrevCell = false, -- Disabled to allow Codeium tab acceptance
          MkdnTableNextRow = false,
          MkdnTablePrevRow = { 'i', '<M-CR>' },
          MkdnTableNewRowBelow = { 'n', '<leader>ir' },
          MkdnTableNewRowAbove = { 'n', '<leader>iR' },
          MkdnTableNewColAfter = { 'n', '<leader>ic' },
          MkdnTableNewColBefore = { 'n', '<leader>iC' },
          MkdnFoldSection = { 'n', '<leader>f' },
          MkdnUnfoldSection = { 'n', '<leader>F' },
        },
      })
    end,
  },
}
