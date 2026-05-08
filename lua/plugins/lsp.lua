-- TODO: disable plugins that only work for terminal
local shouldEnablePlugin = vim.g.vscode == nil

local plugins = {
    -- LSP config
    {
        "neovim/nvim-lspconfig",
        enabled = shouldEnablePlugin,
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
        enabled = shouldEnablePlugin,
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
        enabled = shouldEnablePlugin,
    },
    -- additional list of LSPs, linters, and formatters
    {
        "mason-org/mason-registry",
        enabled = shouldEnablePlugin,
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
        end,
        enabled = shouldEnablePlugin,
    },
    -- auto-installs for linters
    {
        "rshkarin/mason-nvim-lint",
        config = function()
            require("mason-nvim-lint").setup({
                automatic_installation = true,
            })
        end,
        enabled = shouldEnablePlugin,
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
            -- TODO: fix behaviors with formatting and stuff like tab vs space
            vim.keymap.set("n", "<leader>af", ":lua require(\"conform\").format({ async = false, lsp_fallback = true, })<CR>", { silent = true, desc="Auto-format the current file" })
        end,
        enabled = shouldEnablePlugin,
    },
    -- auto-install for formatters
    {
        "zapling/mason-conform.nvim",
        config = function()
            require("mason-conform").setup({})
        end,
        enabled = shouldEnablePlugin,
    },
    {
        "hedyhli/outline.nvim",
        config = function()
            vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle Outline" })
            require("outline").setup({})
        end,
        enabled = shouldEnablePlugin,
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
        end,
        enabled = shouldEnablePlugin,
    },
    -- shows the actual error/warning text when the cursor is on the line in question
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy",
        priority = 1000,
        config = function()
            vim.diagnostic.config({
                underline = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "",
                        [vim.diagnostic.severity.WARN] = "",
                        [vim.diagnostic.severity.HINT] = "",
                        [vim.diagnostic.severity.INFO] = "",
                    },
                },
            })
            require("tiny-inline-diagnostic").setup({
                -- transparent_bg = true,
                -- transparent_cursorline = true,
                options = {
                    preset = "powerline",
                    -- overflow = {
                    --     mode = "wrap",
                    -- }
                    -- break_line = {
                    --     enabled = true,
                    --     after = 10,
                    -- }
                },
            })
            vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
        end,
        enabled = shouldEnablePlugin,
    },
    -- show diagnostics window for errors/warnings in the entire file
    {
        "folke/trouble.nvim",
        opts = {}, -- for default options, refer to the configuration section for custom setup.
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xl",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xq",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
        enabled = shouldEnablePlugin,
    },
    -- LSP status notifications
    {
        "j-hui/fidget.nvim",
        version = "*",
        options = {
            -- options
        },
        config = function()
            require("telescope").load_extension("fidget")
            require("fidget").setup({})
        end,
        enabled = shouldEnablePlugin,
    },
    -- multiple LSP UI components
    -- TODO: figure out keymaps and also if we need goto-preview or not
    {
        "nvimdev/lspsaga.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter", -- optional
            "nvim-tree/nvim-web-devicons",     -- optional
        },
        -- event = "LspAttach",
        config = function()
            require("lspsaga").setup({})
            -- keymaps for goto definition
            vim.keymap.set("n", "gd", vim.lsp.buf.definition)
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
            vim.keymap.set("n", "<leader>ca", ":Lspsaga code_action<CR>", { desc="Open code action ", silent=true })
        end,
        enabled = shouldEnablePlugin,
    },
    -- preview functions, references, etc.
    {
        "rmagatti/goto-preview",
        dependencies = { "rmagatti/logger.nvim" },
        event = "BufEnter",
        config = true, -- necessary as per https://github.com/rmagatti/goto-preview/issues/88
        init = function()
            require("goto-preview").setup({
                default_mappings = true,
            })
        end,
        enabled = shouldEnablePlugin,
    },
}

return plugins
