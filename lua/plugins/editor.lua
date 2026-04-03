return {
    -- auto pairing for [{("")}], etc.
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true
        -- use opts = {} for passing setup options
        -- this is equivalent to setup({}) function
    },
    -- git sign integration
    {
        "lewis6991/gitsigns.nvim",
        dependencies = { "Mofiqul/vscode.nvim" },
        config = function()
            vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#00ff00" })
            vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#ffff00" })
            vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#ff5555" })
            -- Other variables for color
            -- GitSignsAdd
            -- GitSignsChange
            -- GitSignsDelete
            -- GitSignsTopdelete
            -- GitSignsChangedelete
            -- GitSignsUntracked
        end
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
