return {
    -- LSP config
    {
        "neovim/nvim-lspconfig",
    },
    -- installer for LSPs, linters, and formatters
    {
        "mason-org/mason.nvim",
        opts = {
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "x",
                }
            }
        },
        config = function()
            require("mason").setup({
                PATH = "prepend",
            })
        end,
    },
    -- auto-install for LSPs
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {
                "clangd",        -- C/C++
                "cssls",         -- CSS
                "dockerls",      -- Docker
                "html",          -- HTML
                "jsonls",        -- JSON
                "lua_ls",        -- Lua
                "pyright",       -- Python
                "rust_analyzer", -- Rust
                "ts_ls",         -- JavaScript/TypeScript
            },
        },
        dependencies = {
            {
                "mason-org/mason.nvim",
                opts = {}
            },
            "neovim/nvim-lspconfig",
        },
        config = function(_, opts)
            require("mason-lspconfig").setup(opts)
            -- stops lua_ls from complaining about `vim` not being a global variable
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        }
                    }
                }
            })
        end,
    },
    -- additional list of LSPs, linters, and formatters
    {
        "mason-org/mason-registry",
    },
    -- linter
    {
        "mfussenegger/nvim-lint",
        config = function()
            -- Add Mason binaries to Neovim path
            vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.stdpath("data") .. "/mason/bin"

            require("mason").setup()

            -- local registry = require("mason-registry")
            local lint = require("lint")

            lint.linters_by_ft = {
                -- C no need for linter
                -- C++ no need for linter
                css = { "stylelint" },
                dockerfile = { "hadolint" },
                -- HTML no need for linter
                -- JSON no need for linter
                -- lua = { "luacheck" },
                python = { "ruff" },
                -- Rust no need for linter
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
            }
            -- Trigger linting automatically
            vim.api.nvim_create_autocmd(
                {
                    "BufEnter",
                    "BufWritePost",
                    "InsertLeave"
                },
                {
                    callback = function()
                        require("lint").try_lint()
                    end,
                }
            )
        end
    },
    -- auto-installs for linters
    {
        "rshkarin/mason-nvim-lint",
        config = function()
            require("mason-nvim-lint").setup({
                automatic_installation = true,
            })
        end
    },
    -- formatter
    {
        "stevearc/conform.nvim",
        opts = {},
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    c = { "clang-format" },
                    cpp = { "clang-format" },
                    css = { "prettierd" },
                    -- dockerfile no need for formatter
                    html = { "prettierd" },
                    json = { "prettierd" },
                    lua = { "stylua" },
                    python = { "black" },
                    rust = { "rustfmt" },
                    javascript = { "prettierd" },
                    typescript = { "prettierd" },
                },
            })
        end,
    },
    -- auto-install for formatters
    {
        "zapling/mason-conform.nvim",
        config = function()
            require("mason-conform").setup({})
        end
    },
    {
        "rmagatti/goto-preview",
        dependencies = { "rmagatti/logger.nvim" },
        event = "BufEnter",
        config = true, -- necessary as per https://github.com/rmagatti/goto-preview/issues/88
        init = function()
            require("goto-preview").setup({
                default_mappings = true,
            })
        end
    },
    {
        "hedyhli/outline.nvim",
        config = function()
            vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle Outline" })
            require("outline").setup({})
        end,
    },
    -- shows number of references, etc.
    {
        'Wansmer/symbol-usage.nvim',
        event = 'BufReadPre', -- need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
        config = function()
            require('symbol-usage').setup({
                hl = { link = "NonText" },
                kinds = {
                    vim.lsp.protocol.SymbolKind.Function,
                    vim.lsp.protocol.SymbolKind.Method,
                    vim.lsp.protocol.SymbolKind.Class,
                    vim.lsp.protocol.SymbolKind.Struct,
                    vim.lsp.protocol.SymbolKind.Module,
                    vim.lsp.protocol.SymbolKind.Interface,
                },
                vt_position = "end_of_line",
            })
        end
    },
}
