-- CMake integration via cmake-tools.nvim (the same plugin LazyVim's lang.cmake
-- extra uses). We add it directly instead of importing that extra, because the
-- extra also pulls in Mason-installed CMake linters we do not want.
--
-- Workflow: <leader>mg (generate) -> <leader>mb (build) -> <leader>mr (run)
--           <leader>md (debug with nvim-dap using GDB)
-- compile_commands.json is exported and soft-linked into the project root so
-- clangd finds it with no extra setup.

return {
  {
    "Civitasv/cmake-tools.nvim",
    cmd = {
      "CMakeGenerate",
      "CMakeBuild",
      "CMakeRun",
      "CMakeDebug",
      "CMakeSelectBuildType",
      "CMakeSelectBuildTarget",
    },
    ft = { "cmake" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>m", "", desc = "+cmake" },
      { "<leader>mg", "<cmd>CMakeGenerate<cr>", desc = "CMake generate" },
      { "<leader>mb", "<cmd>CMakeBuild<cr>", desc = "CMake build" },
      { "<leader>mr", "<cmd>CMakeRun<cr>", desc = "CMake run" },
      { "<leader>md", "<cmd>CMakeDebug<cr>", desc = "CMake debug" },
      { "<leader>mt", "<cmd>CMakeSelectBuildType<cr>", desc = "CMake build type" },
      { "<leader>mT", "<cmd>CMakeSelectBuildTarget<cr>", desc = "CMake build target" },
    },
    opts = {
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1", "-G", "Ninja" },
      cmake_build_directory = "build",
      cmake_soft_link_compile_commands = true,
      -- Debug with GDB through the adapter defined in plugins/dap.lua.
      cmake_dap_configuration = { name = "cpp", type = "gdb", request = "launch" },
    },
  },
}
