return {
    -- color theme
    {
        "Mofiqul/vscode.nvim",
        config = function()
            vim.o.background = "dark"
            local c = require("vscode.colors").get_colors()
            require("vscode").setup({
                transparent = true,
                italic_comments = true,
                italic_inlayhints = true,
                underline_links = true,
                disable_nvimtree_bg = true, -- disables nvim-tree bg color
                terminal_colors = true,
                color_overrides = {
                    vscLineNumber = "#FFFFFF",
                },
                group_overrides = {
                    Cursor = { fg=c.vscDarkBlue, bg=c.vscLightGreen, bold=true },
                }
            })
            vim.cmd.colorscheme "vscode"
        end,
    },
    -- indentation guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        ---@module "ibl"
        ---@type ibl.config
        opts = {},
    },
    -- notification UI
    {
        "rcarriga/nvim-notify",
        config = function()
            vim.notify = require("notify")
            vim.notify.setup({
                timeout = 500,
                background_colour = "#000000",
            })
        end,
    },
    -- darkens non-focused splits
    {
        "sunjon/shade.nvim",
        config = function()
            require("shade").setup({
                overlay_opacity = 25,
            })
        end,
    },
    -- TODO comment highlighting
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("todo-comments").setup({})

            vim.keymap.set("n", "]t", function()
                require("todo-comments").jump_next()
            end, { desc = "Next todo comment" })

            vim.keymap.set("n", "[t", function()
                require("todo-comments").jump_prev()
            end, { desc = "Previous todo comment" })
        end,
    },
    -- additional icons
    {
        "nvim-tree/nvim-web-devicons",
        opts = {},
    },
    -- undo tree
    {
        "jiaoshijie/undotree",
        opts = {
            -- your options
        },
        keys = { -- load the plugin only when using it's keybinding:
            { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>", desc="Toggles the undo tree", },
        },
    },
    -- keymap helper
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            -- win = {
                -- height = { min=10, max=20 },
                -- width = { min=20, max=35 },
            -- },
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },
}
