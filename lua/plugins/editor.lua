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
        ---@diagnostic disable-next-line: undefined-doc-name
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
    -- lua with lazy.nvim
    {
        "max397574/better-escape.nvim",
        config = function()
            vim.o.timeoutlen = 100
            require("better_escape").setup({
                timeout = 100, -- milliseconds, doesn't seem to work though
                default_mappings = false,
                mappings = {
                    i = {
                        j = {
                            k = "<Esc>",
                            -- j = "<Esc>",
                        },
                        k = {
                            j = "<Esc>",
                        },
                    },
                    c = {
                        j = {
                            k = "<Esc>",
                            -- j = "<Esc>",
                        },
                        k = {
                            j = "<Esc>",
                        },
                    },
                    s = {
                        j = {
                            k = "<Esc>",
                            -- j = "<Esc>",
                        },
                        k = {
                            j = "<Esc>",
                        },
                    },
                }
            })
        end,
    },
    -- more all/inner objects (e.g. *asdf*, yi*)
    {
        "nvim-mini/mini.nvim",
        version = "*",
        config = function()
            require("mini.ai").setup({})
        end,
    },
    -- Git integration
    {
        "tpope/vim-fugitive",
    },
    -- fast movements with f, t, and s
    {
        "folke/flash.nvim",
        event = "BufReadPost",
        ---@diagnostic disable-next-line: undefined-doc-name
        ---@type Flash.Config
        opts = {
            continue = false,
            modes = {
                char = {
                    -- overrides f/t to be multi-line and letter highlighting
                    enabled = true,
                    jump_labels = false,

                    -- turns off hl group highlighting for f/t
                    highlight = {
                        backdrop = false,
                    }
                }
            },
            jump = {
                autojump = true,
            },
            -- if you want to turn off the comment hl group from activating for `s`
            -- highlight = {
            --     backdrop = false,
            -- }
        },
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
            { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
            { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
        },
    }
}
