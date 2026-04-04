return {
    -- auto pairing for [{("")}], etc.
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true
        -- use opts = {} for passing setup options
        -- this is equivalent to setup({}) function
    },
    -- comment plugin (in addition to Neovim built-in commenting)
    {
        "numToStr/Comment.nvim",
        opts = {
            -- add any options here
        }
    },
    {
        'andymass/vim-matchup',
        init = function()
            -- modify your configuration vars here
            vim.g.matchup_treesitter_stopline = 500

            -- or call the setup function provided as a helper. It defines the
            -- configuration vars for you
            require('match-up').setup({
                treesitter = {
                    stopline = 500
                }
            })
        end,
        -- or use the `opts` mechanism built into `lazy.nvim`. It calls
        -- `require('match-up').setup` under the hood
        ---@type matchup.Config
        opts = {
            treesitter = {
                stopline = 500,
            }
        }
    },
    -- comment frame
    {
        "s1n7ax/nvim-comment-frame",
        requires = {
            { "nvim-treesitter" }
        },
        config = function()
            require("nvim-comment-frame").setup()
        end
    },
    -- resetore last cursor position since file close
    {
        "nxhung2304/lastplace.nvim",
        config = function()
            require("lastplace").setup({
            -- your configuration here
            })
        end,
    },
    -- surrounds objects with things like "", (), [], {}, '', <tag></tag>, etc.
    {
        "kylechui/nvim-surround",
        version = "^4.0.0", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        -- Optional: See `:h nvim-surround.configuration` and `:h nvim-surround.setup` for details
        config = function()
            -- require("nvim-surround").setup({
            --     -- Put your configuration here
            -- })
        end,
    },
    --[[ {
        "https://codeberg.org/andyg/leap.nvim",
        config = function()
            require("leap").leap { windows = { vim.fn.win_getid() } }
            vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
            vim.keymap.set("n", "S", "<Plug>(leap-from-window)")
        end
    }, ]]
}
