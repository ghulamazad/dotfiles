-- Mason downloads prebuilt binaries from the internet. LazyVim's defaults
-- (and the clangd extra) ask it to install stylua, shfmt and codelldb on
-- startup. We turn that off: tools come from pacman, which is signed, covered
-- by system updates and works offline. Mason itself stays available for
-- manual use (:Mason) if you decide to trust a specific package.
--
-- Install the tools instead:
--   pacman -S clang gdb lldb cmake ninja bear stylua shfmt tree-sitter-cli

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = {}
    end,
  },
}
