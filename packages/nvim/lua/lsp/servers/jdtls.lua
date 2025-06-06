-- Java LSP server configuration
return {
  settings = {
    java = {
      configuration = {
        updateBuildConfiguration = 'automatic',
        maven = {
          downloadSources = true,
        },
        gradle = {
          enabled = true,
          wrapper = {
            enabled = true,
          },
          java = {
            home = '/usr/lib/jvm/java-24-openjdk',
          },
          offline = {
            enabled = false,
          },
          arguments = '--stacktrace',
          annotationProcessing = {
            enabled = true,
          },
          validation = {
            enabled = true,
            async = true,
          },
        },
      },
      project = {
        referencedLibraries = { 'lib/**/*.jar', 'build/libs/**/*.jar' },
      },
      format = {
        enabled = true,
        settings = {
          url = 'https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml',
          profile = 'GoogleStyle',
        },
      },
    },
  },
  root_dir = function(fname)
    return require('lspconfig.util').root_pattern(
      'build.gradle',
      'build.gradle.kts',
      'settings.gradle',
      'settings.gradle.kts',
      'pom.xml',
      '.git'
    )(fname) or vim.fn.getcwd()
  end,
}
