# GhulamAzad's Neovim configuration

Adapted from [ThePrimeagen/init.lua](https://github.com/ThePrimeagen/init.lua)
at commit `b2417cdcc842af1ab06f84b8ad142552e738e648` (default branch `master`,
2026-09-02). Targets Neovim 0.12.x, Arch/Omarchy, Ghostty, QWERTY; main
languages Rust, C/C++ (and Go).

Lua namespace: `ghulamazad` (augroups `GhulamAzad*`). Plugin manager: lazy.nvim
(unchanged from upstream).

## Layout

```
init.lua                       -> require("ghulamazad")
lua/ghulamazad/init.lua        autocmds, LspAttach keymaps, netrw, R()
lua/ghulamazad/set.lua         options
lua/ghulamazad/remap.lua       global keymaps
lua/ghulamazad/lazy_init.lua   lazy.nvim bootstrap
lua/ghulamazad/cmake.lua       :CMakeCompdb (new, small)
lua/ghulamazad/lazy/*.lua      one plugin spec per file (lazy.nvim imports the dir)
lazy-lock.json                 regenerated against these specs
```

## External tools

Servers are enabled only when the binary is in PATH: `clangd`, `rust-analyzer`,
`gopls`, `lua-language-server`. Formatters: `clang-format`, `rustfmt`, `gofmt`
(missing ones are skipped; LSP formatting is the fallback). Debugging uses
`gdb` >= 14 (built-in DAP server); Go debugging needs `dlv`. Treesitter parser
installs need the `tree-sitter` CLI and a C compiler. `:Mason` can install
gopls / delve / lua-language-server if you do not want them from pacman.

## Deliberate behaviour changes vs upstream (all bugs or Neovim 0.12 breakage)

* Upstream `lsp.lua` called `conform.setup()` a second time; conform recreates its
  `Conform` augroup on every setup, which silently removed format-on-save. Removed.
* LSP now uses `vim.lsp.config()` / `vim.lsp.enable()`; `require("lspconfig")[x].setup`
  is gone. `:LspRestart` does not exist on 0.12, so `:lsp restart` is used.
* `[d`/`]d` and `[t`/`]t` were swapped (and Trouble `previous` does not exist). Native
  direction restored.
* nvim-treesitter is pinned to `branch = "main"`; textobjects keymaps were inert on
  `main` and are now explicit mappings. Parser list: web parsers dropped, c/cpp/rust/
  cmake/make/toml/markdown/bash/go* added.
* Telescope pinned tag 0.1.5 predates 0.11+ support -> `v0.2.2`.
* friendly-snippets was installed but never loaded -> `lazy_load()` added.
* `:colorscheme` ran on every BufEnter (to special-case Zig) -> applied once.
* Trailing-whitespace strip keeps cursor and search pattern.
* undodir moved from `~/.vim/undodir` to Neovim's state dir.
* Harpoon came from a local `~/personal/harpoon` checkout -> public `harpoon2` branch.
* lazy.nvim luarocks support disabled (only plenary ships a rockspec; not needed).

## Plugin audit

| Plugin | Class | Notes |
|---|---|---|
| lazy.nvim | Keep | upstream manager |
| plenary.nvim | Keep | dep of telescope, harpoon, neotest, vim-be-good |
| nvim-lspconfig | Keep | now only supplies `lsp/*.lua` defaults |
| nvim-cmp, cmp-nvim-lsp, cmp-buffer, cmp-path, cmp_luasnip | Keep | cmp-path was declared upstream but unused; now a source |
| LuaSnip, friendly-snippets | Keep | C/C++/Rust/Go snippets |
| fidget.nvim | Keep | LSP progress |
| conform.nvim | Keep | clang-format, rustfmt, gofmt |
| nvim-treesitter, -textobjects | Keep | `main` branch |
| telescope.nvim | Keep | needs ripgrep for grep |
| harpoon (harpoon2) | Keep | |
| vim-fugitive | Keep | |
| trouble.nvim | Keep | |
| undotree | Keep | |
| zen-mode.nvim | Keep | |
| cloak.nvim | Keep | hides `.env` secrets |
| nvim-dap, nvim-dap-ui, nvim-nio | Keep | GDB adapter for C/C++/Rust |
| nvim-dap-go | Keep | Go debugging + neotest dap strategy |
| neotest, neotest-golang, FixCursorHold.nvim | Keep | Go only (see below) |
| rose-pine, tokyonight | Not used by the repo | |
| mason.nvim | Optional | manual installer, installs nothing automatically |
| gruvbox, brightburn | Optional | lazy, load on `:colorscheme` |
| cellular-automaton | Optional | `<leader>ca`, lazy |
| vim-be-good | Optional | `:VimBeGood`, lazy |
| mason-lspconfig | Removed | redundant with native vim.lsp.enable; its ensure_installed pulled servers you already have or do not use |
| mason-nvim-dap | Removed | only installed delve; GDB has a built-in DAP server, dlv comes from PATH/:Mason |
| cmp-cmdline | Removed | declared upstream, never configured |
| supermaven-nvim | Removed | AI completion service: account, downloaded binary, background process |
| golf (vuciv/golf) | Removed | Vim-golf game |
| jai.vim | Removed | Jai language |
| php.nvim (tjdevries) | Removed | PHP |
| 99 (local dir, Cursor agent) | Removed | not public in this form; needs cursor-agent |
| peek.nvim (commented out) | Removed | needs deno |
| copilot (unused_copilot.lua) | Removed | dead commented file |
| markdown.lua | Removed | empty spec |
| vtsls / tailwindcss / zls configs, templ filetype | Removed | web/Zig tooling |
| vim-with-me keymaps | Removed | plugin never installed |

No plugins were added beyond upstream's set.

## Testing coverage

Rust and C/C++ have no neotest adapter: neotest-rust needs `cargo-nextest` and the
C++ adapters need a specific framework (gtest/catch2), none of which are assumed
installed. Add one if you use them.

## Keymaps

Leader is Space. Run `:map <leader>` or use telescope `keymaps`; all mappings carry a
`desc`. See the migration table delivered with this config for upstream -> new.

| Key | Action |
|---|---|
| `<leader>a` / `<C-e>` | Harpoon add / quick menu |
| `<leader>h j k l` | Harpoon slots 1-4 (`<leader>A` prepends) |
| `<C-w>h/j/k/l` | native window navigation (untouched) |
| `<C-j>` / `<C-k>` | quickfix prev / next |
| `[l` / `]l` | location list prev / next |
| `[d` / `]d` | diagnostic prev / next |
| `gd` `K` `<leader>vca` `<leader>vrn` `<leader>vrr` `<leader>vws` `<leader>vd` | LSP |
| `<leader>vsh` | clangd: switch source/header |
| `<leader>vlr` | `:lsp restart` |
| `<leader>f` | format (also on save) |
| `<leader>pf` `<C-p>` `<leader>ps` `<leader>pws` `<leader>vh` | telescope |
| `<leader>gs` | fugitive; in it: `<leader>p` push, `<leader>P` pull --rebase |
| `<F8>` `<F10>` `<F11>` `<F12>` | dap continue / over / into / out |
| `<leader>b` `<leader>B` | breakpoint / conditional |
| `<leader>D{r,s,w,b,S,c}` | dap-ui panels |
| `<leader>tt` | Trouble diagnostics; `]t` `[t` next/prev |
| `<leader>u` `<leader>zz` | undotree, zen mode |

`:CMakeCompdb [build_dir]` configures CMake with Ninja, exports
`compile_commands.json` and links it into the project root for clangd.
