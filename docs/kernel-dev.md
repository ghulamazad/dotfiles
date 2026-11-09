# Kernel / systems development notes

Neovim detects a Linux kernel tree (needs `Kbuild`, `Kconfig`, `MAINTAINERS` and
`scripts/kconfig`; see `nvim/lua/util/kernel.lua`) and changes behaviour there:

- Tabs, width 8, textwidth 80, no autoformat (kernel style, not clang-format defaults).
- clangd: background index, clang-tidy and header insertion off (a kernel tree is huge).
- No generic C++ flags are applied globally anywhere.

## compile_commands.json for the kernel
Generate it from the kernel tree with the kernel's own script:
`python3 scripts/clang-tools/gen_compile_commands.py` (after a build). Building with
LLVM (`make LLVM=1`) gives clangd the fewest flag mismatches with GCC-only options;
I have not tested this setup.

## Debugging
`nvim-dap` uses `gdb --interpreter=dap` (GDB 14+ required for DAP) and `lldb-dap`.
Check `gdb --version`. Kernel debugging via QEMU `-s -S` plus `gdb vmlinux` and
`target remote :1234` is standard but not preconfigured here.

## Projects
CMake: `cmake -S . -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`.
Makefile: `bear -- make`.
