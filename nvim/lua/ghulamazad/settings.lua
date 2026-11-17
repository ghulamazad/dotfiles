-- THE file to edit when you want to change how this config behaves.
-- Everything else reads from here; you should not need to touch the plugin
-- files for everyday changes. Each section says what it controls.

return {
    leader = " ",
    theme = "petrol-lagoon",

    -- Plain Neovim options. These are merged over the defaults in core/options.lua,
    -- so list only what you want to change or add. Names are the `vim.opt` names.
    options = {
        -- tabstop = 2, shiftwidth = 2, softtabstop = 2,
        -- colorcolumn = "100",
        -- relativenumber = false,
    },

    -- Strip trailing whitespace on save (cursor and search pattern are kept).
    strip_trailing_whitespace = true,

    -- Turn a whole group of plugins off by setting it to false. A disabled
    -- feature is not installed or loaded, and its keymaps do not exist.
    features = {
        completion = true,  -- nvim-cmp + sources + snippets
        lsp        = true,  -- language servers (nvim-lspconfig, fidget)
        format     = true,  -- conform.nvim, format on save
        treesitter = true,  -- syntax, parsers, function text objects
        telescope  = true,  -- fuzzy finder
        harpoon    = true,  -- quick file marks
        fugitive   = true,  -- git
        trouble    = true,  -- diagnostics list
        undotree   = true,
        zen        = true,  -- zen-mode
        cloak      = true,  -- hides secrets in .env files
        debug      = true,  -- nvim-dap, dap-ui, GDB / Go debugging
        test       = true,  -- neotest (Go)
        mason      = true,  -- :Mason manual installer, nothing installed for you
        toys       = true,  -- cellular-automaton, vim-be-good (lazy, load on use)
    },

    -- Language servers, enabled only when the binary exists in PATH.
    -- name (as in nvim-lspconfig) = { bin = "<binary>", config = <table or function returning a table> }
    -- Add a language: add a line here, then add its parser/formatter below.
    servers = {
        clangd = {
            bin = "clangd",
            config = {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                },
            },
        },
        rust_analyzer = { bin = "rust-analyzer" },
        gopls = { bin = "gopls" },
        lua_ls = {
            bin = "lua-language-server",
            config = function()
                return {
                    settings = {
                        Lua = {
                            runtime = { version = "LuaJIT" },
                            diagnostics = { globals = { "vim" } },
                            workspace = {
                                library = vim.api.nvim_get_runtime_file("", true),
                                checkThirdParty = false,
                            },
                        },
                    },
                }
            end,
        },
    },

    -- Formatters per filetype (conform.nvim). A missing binary is skipped and the
    -- LSP formatter is used instead.
    formatters = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        rust = { "rustfmt" },
        go = { "gofmt" },
    },
    -- Extra arguments for a formatter.
    formatter_args = {
        ["clang-format"] = { "-style=file", "-fallback-style=LLVM" },
    },

    -- Treesitter parsers installed in the background (needs the tree-sitter CLI
    -- and a C compiler).
    parsers = {
        "lua", "vim", "vimdoc", "query", "json", "gitignore",
        "go", "gomod", "gosum", "c", "cpp", "rust", "cmake", "make",
        "toml", "markdown", "markdown_inline", "bash",
    },

    -- Files whose values are hidden by cloak.nvim.
    cloak = {
        file_pattern = { ".env*", "wrangler.toml", ".dev.vars" },
        cloak_pattern = "=.+",
    },

    -- Debug adapters. The executable path is asked for when you start debugging;
    -- the value is the folder it starts in, relative to the project.
    debug = {
        gdb_start_dir = { c = "/", cpp = "/", rust = "/target/debug/" },
    },
}
