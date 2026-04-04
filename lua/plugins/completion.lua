return {
    -- completion engine
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                window = {
                    -- completion = cmp.config.window.bordered(), -- uncommenting this makes the completion popup match the terminal background
                    -- documentation = cmp.config.window.bordered(), -- didn't seem to really change anything
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                }),
                sources = cmp.config.sources(
                    {
                        { name = 'nvim_lsp' },
                    },
                    {
                        { name = 'buffer' },
                    }
                )
            })
            -- completion for / and ? search
            cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })
            -- completion for Neovim command mode
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources(
                    {
                        { name = 'path' }
                    },
                    {
                        { name = 'cmdline' }
                    }
                ),
                matching = { disallow_symbol_nonprefix_matching = false },
            })
            -- integration with lspkind
            local lspkind = require("lspkind")
            cmp.setup {
                formatting = {
                    fields = { 'abbr', 'icon', 'kind', 'menu' },
                    format = lspkind.cmp_format({
                        maxwidth = {
                            -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                            -- can also be a function to dynamically calculate max width such as
                            -- menu = function() return math.floor(0.45 * vim.o.columns) end,
                            menu = 50, -- leading text (labelDetails)
                            abbr = 50, -- actual suggestion item
                        },
                        ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                        show_labelDetails = true, -- show labelDetails in menu. Disabled by default

                        -- The function below will be called before any actual modifications from lspkind
                        -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
                        before = function (entry, vim_item)
                            -- ...
                            return vim_item
                        end
                    })
                }
            }
        end,
    },
    -- shows function definition as you type the function call
    {
        "ray-x/lsp_signature.nvim",
        event = "InsertEnter",
        opts = {},
    },
    -- nice icons for completion menu
    {
        "onsails/lspkind.nvim",
    },
    -- TODO: find better virtual text plugin
    -- TODO: should I use outline.nvim or the one built into trouble.nvim?
    -- show error/diagnostic text
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
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
    },
    -- {
    --     "nvim-lua/lsp-status.nvim",
    --     config = function()
    --         local lsp_status = require("lsp-status")
    --         lsp_status.register_progress()
    --         lsp_status.config({})
    --     end
    -- },
    -- shows errors with virtual text
    -- {
    --     "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    --     config = function()
    --         require("lsp_lines").setup({})
    --         vim.diagnostic.config({
    --             virtual_text = true,
    --             virtual_lines = false,
    --             underline = false,
    --             signs = true,
    --         })
    --     end,
    -- },
    -- shows lightbulb to indicate possible code action
    -- {
    --     "kosayoda/nvim-lightbulb",
    --     config = function()
    --         require("nvim-lightbulb").setup({})
    --     end
    -- },
}
