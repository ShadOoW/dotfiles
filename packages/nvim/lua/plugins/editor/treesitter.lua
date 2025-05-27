-- Treesitter configuration
return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
    opts = {
        ensure_installed = {"html", "css", "typescript", "tsx", "javascript", "astro"},
        auto_install = true,
        highlight = {
            enable = true
        },
        indent = {
            enable = true
        },
        autotag = {
            enable = true
        }
    },
    dependencies = {"windwp/nvim-ts-autotag"}
}
