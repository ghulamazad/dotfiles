-- Detect whether a path is inside a Linux kernel source tree.
-- Used to switch clangd and indentation settings so ordinary C/C++ flags and
-- style are never applied to kernel code.

local M = {}

local cache = {}

--- Return the kernel tree root containing `path`, or nil.
--- A tree counts as the kernel if the top directory has Kbuild, Kconfig,
--- MAINTAINERS and scripts/kconfig (all present in mainline Linux).
---@param path? string file or directory; defaults to the current buffer
---@return string?
function M.root(path)
  path = path or vim.api.nvim_buf_get_name(0)
  if path == nil or path == "" then
    path = vim.uv.cwd()
  end
  if cache[path] ~= nil then
    return cache[path] or nil
  end

  local dir = vim.fs.dirname(path)
  if vim.fn.isdirectory(path) == 1 then
    dir = path
  end

  local found = vim.fs.find("Kbuild", { path = dir, upward = true, type = "file", limit = 1 })[1]
  local root
  if found then
    local top = vim.fs.dirname(found)
    local uv = vim.uv
    if
      uv.fs_stat(top .. "/Kconfig")
      and uv.fs_stat(top .. "/MAINTAINERS")
      and uv.fs_stat(top .. "/scripts/kconfig")
    then
      root = top
    end
  end

  cache[path] = root or false
  return root
end

return M
