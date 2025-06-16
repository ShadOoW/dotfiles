-- Gutentags: Automatic ctags generation and management
return {
  'ludovicchabant/vim-gutentags',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    -- Configure gutentags
    vim.g.gutentags_enabled = 1

    -- Project root markers (prioritize git and common build files)
    vim.g.gutentags_project_root = {
      '.git',
      '.hg',
      '.svn',
      '.bzr',
      '_darcs',
      '_FOSSIL_',
      '.fslckout',
      'package.json',
      'Cargo.toml',
      'go.mod',
      'build.gradle',
      'build.gradle.kts',
      'settings.gradle',
      'settings.gradle.kts',
      'pom.xml',
      'Makefile',
      'CMakeLists.txt',
      'meson.build',
      '.project',
      '.classpath',
    }

    -- Store tags files in cache directory to keep project clean
    vim.g.gutentags_cache_dir = vim.fn.stdpath('cache') .. '/ctags'

    -- Create cache directory if it doesn't exist
    vim.fn.mkdir(vim.g.gutentags_cache_dir, 'p')

    -- File types to generate tags for
    vim.g.gutentags_ctags_tagfile = 'tags'

    -- Simplified ctags options to prevent job failures
    vim.g.gutentags_ctags_extra_args = {
      '--tag-relative=yes',
      '--fields=+ailmnS',
      '--extra=+q',
      '--recurse=yes',
      '--sort=yes',
      '--exclude=.git',
      '--exclude=.svn',
      '--exclude=.hg',
      '--exclude=node_modules',
      '--exclude=build',
      '--exclude=target',
      '--exclude=dist',
      '--exclude=.gradle',
      '--exclude=.idea',
      '--exclude=.vscode',
      '--exclude=*.class',
      '--exclude=*.jar',
      '--exclude=*.log',
      '--exclude=*.tmp',
      '--exclude=*.swp',
      '--exclude=*.min.*',
      '--exclude=*.map',
    }

    -- Keep language mappings simple to avoid ctags errors
    -- Use built-in language support when possible

    -- Generate tags only for specific file types to improve performance
    vim.g.gutentags_file_list_command = {
      markers = {
        ['.git'] = 'git ls-files',
        ['.hg'] = 'hg files',
      },
    }

    -- Define which files should trigger tag generation
    vim.g.gutentags_generate_on_new = 1
    vim.g.gutentags_generate_on_missing = 1
    vim.g.gutentags_generate_on_write = 1
    vim.g.gutentags_generate_on_empty_buffer = 0

    -- Exclude certain file types from tag generation
    vim.g.gutentags_ctags_exclude = {
      '*.git',
      '*.svg',
      '*.hg',
      '*/tests/*',
      'build',
      'dist',
      '*sites/*/files/*',
      'bin',
      'node_modules',
      'bower_components',
      'cache',
      'compiled',
      'docs',
      'example',
      'bundle',
      'vendor',
      '*.md',
      '*-lock.json',
      '*.lock',
      '*bundle*.js',
      '*build*.js',
      '*.json',
      '*.min.*',
      '*.map',
      '*.bak',
      '*.zip',
      '*.pyc',
      '*.class',
      '*.sln',
      '*.Master',
      '*.csproj',
      '*.tmp',
      '*.csproj.user',
      '*.cache',
      '*.pdb',
      'tags*',
      'cscope.*',
      '*.css',
      '*.less',
      '*.scss',
      '*.exe',
      '*.dll',
      '*.mp3',
      '*.ogg',
      '*.flac',
      '*.swp',
      '*.swo',
      '*.bmp',
      '*.gif',
      '*.ico',
      '*.jpg',
      '*.png',
      '*.rar',
      '*.zip',
      '*.tar',
      '*.tar.gz',
      '*.tar.xz',
      '*.tar.bz2',
      '*.pdf',
      '*.doc',
      '*.docx',
      '*.ppt',
      '*.pptx',
    }

    -- Advanced configuration: different tag files for different languages
    vim.g.gutentags_modules = { 'ctags' }

    -- Status line integration
    vim.g.gutentags_add_default_project_roots = 0

    -- Commands for manual tag management
    vim.api.nvim_create_user_command('GutentagsToggle', function()
      if vim.g.gutentags_enabled == 1 then
        vim.g.gutentags_enabled = 0
        require('utils.notify').info('Gutentags disabled')
      else
        vim.g.gutentags_enabled = 1
        require('utils.notify').success('Gutentags enabled')
      end
    end, {
      desc = 'Toggle gutentags on/off',
    })

    vim.api.nvim_create_user_command('GutentagsUpdate', function() vim.cmd('GutentagsUpdate!') end, {
      desc = 'Force update tags',
    })

    vim.api.nvim_create_user_command('GutentagsClean', function()
      local cache_dir = vim.g.gutentags_cache_dir
      vim.fn.delete(cache_dir, 'rf')
      vim.fn.mkdir(cache_dir, 'p')
      require('utils.notify').success('Gutentags cache cleaned')
    end, {
      desc = 'Clean gutentags cache',
    })

    -- Keymaps for tag navigation
    vim.keymap.set('n', '<C-]>', '<C-]>', {
      desc = 'Go to tag definition',
    })
    vim.keymap.set('n', '<C-t>', '<C-t>', {
      desc = 'Go back from tag',
    })
    vim.keymap.set('n', 'g<C-]>', 'g<C-]>', {
      desc = 'List tag matches',
    })

    -- Enhanced tag jumping with telescope integration
    vim.keymap.set('n', '<leader>tj', function()
      local word = vim.fn.expand('<cword>')
      if word ~= '' then
        require('telescope.builtin').tags({
          default_text = word,
        })
      else
        require('telescope.builtin').tags()
      end
    end, {
      desc = 'Jump to tag (Telescope)',
    })
  end,
}
