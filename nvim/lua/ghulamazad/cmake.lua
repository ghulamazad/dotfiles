vim.api.nvim_create_user_command("CMakeCompdb", function(opts)
    if vim.fn.executable("cmake") ~= 1 or vim.fn.executable("ninja") ~= 1 then
        vim.notify("CMakeCompdb: cmake and ninja must be in PATH", vim.log.levels.ERROR)
        return
    end
    local root = vim.fs.root(0, { "CMakeLists.txt" })
    if not root then
        vim.notify("CMakeCompdb: no CMakeLists.txt found above this buffer", vim.log.levels.ERROR)
        return
    end
    local build = opts.args ~= "" and opts.args or "build"
    vim.system({
        "cmake", "-S", root, "-B", root .. "/" .. build, "-G", "Ninja",
        "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
    }, { text = true }, vim.schedule_wrap(function(res)
        if res.code ~= 0 then
            vim.notify("CMakeCompdb failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
            return
        end
        local link = root .. "/compile_commands.json"
        local target = root .. "/" .. build .. "/compile_commands.json"
        if not vim.uv.fs_stat(link) or vim.uv.fs_lstat(link).type == "link" then
            vim.uv.fs_unlink(link)
            vim.uv.fs_symlink(target, link)
        else
            vim.notify("CMakeCompdb: existing compile_commands.json left in place", vim.log.levels.WARN)
        end
        vim.notify("CMakeCompdb: " .. target)
        vim.cmd("lsp restart")
    end))
end, { nargs = "?", desc = "Configure CMake (Ninja) and export compile_commands.json" })
