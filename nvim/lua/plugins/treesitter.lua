-- Treesitter parsers for systems work. LazyVim uses the nvim-treesitter `main`
-- branch, which compiles parsers locally: it needs the `tree-sitter-cli`
-- package and a C compiler (gcc, from base-devel). Lists are merged with
-- LazyVim's defaults (opts_extend).

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "c",
        "cpp",
        "cmake",
        "make",
        "kconfig", -- Linux Kconfig files
        "devicetree", -- .dts / .dtsi
        "diff",
        "gitcommit",
        "bash",
      },
    },
  },
}
