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
    -- extends % to work with more matchups
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
    -- fast movements with f, t, /, and s
    {
        "folke/flash.nvim",
        event = "BufReadPost",
        ---@diagnostic disable-next-line: undefined-doc-name
        ---@type Flash.Config
        opts = {
            -- TODO: issue with flash only showing some labels for certain searches
            labels = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
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
                },
                search = {
                    -- overrides search
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
    },
    -- peek at line numbers
    {
        "nacro90/numb.nvim",
        config = function()
            require("numb").setup()
        end,
    },
    -- guess indentation style
    {
        "nmac427/guess-indent.nvim",
        config = function()
            require("guess-indent").setup({})
        end
    },
    -- better syntax highlighting detection
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({})
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(ev)
                    local lang = vim.treesitter.language.get_lang(ev.match)
                    local available_langs = require("nvim-treesitter").get_available()
                    local is_available = vim.tbl_contains(available_langs, lang)
                    if is_available then
                        local installed_langs = require("nvim-treesitter").get_installed()
                        local installed = vim.tbl_contains(installed_langs, lang)
                        if not installed then
                            require("nvim-treesitter").install(lang):await(function ()
                            vim.notify("Installed " .. lang .. " parser", vim.log.levels.INFO, { title = "nvim-treesitter" })
                            vim.treesitter.start()
                            require("nvim-treesitter").indentexpr()
                            end)
                        else
                            vim.treesitter.start()
                            require("nvim-treesitter").indentexpr()
                        end
                    end
                end,
            })
        end,
    },
    -- Remote SSH (local file editing)
    {
        "inhesrom/remote-ssh.nvim",
        branch = "master",
        dependencies = {
            "inhesrom/telescope-remote-buffer", --See https://github.com/inhesrom/telescope-remote-buffer for features
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim",
            "neovim/nvim-lspconfig",
            -- nvim-notify is recommended, but not necessarily required into order to get notifcations during operations - https://github.com/rcarriga/nvim-notify
            "rcarriga/nvim-notify",
        },
        config = function ()
            require('telescope-remote-buffer').setup(
                -- Default keymaps to open telescope and search open buffers including "remote" open buffers
                --fzf = "<leader>fz",
                --match = "<leader>gb",
                --oldfiles = "<leader>rb"
            )

            -- setup lsp_config here or import from part of neovim config that sets up LSP
            local lsp_config = vim.lsp.config

            require('remote-ssh').setup({
                on_attach = lsp_config.on_attach,
                capabilities = lsp_config.capabilities,
                filetype_to_server = lsp_config.filetype_to_server,
                async_write_opts = {
                    autosave = false,
                },
            })
        end
    }
}
