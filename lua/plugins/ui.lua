-- commands for toggling shade.nvim, we assume by default it is off (lazy = true)
local shade_active = false
local initialized = false

-- quick visual feedback for what was just yanked
vim.api.nvim_create_autocmd('TextYankPost', {
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 75,
        })
    end,
})

local function shade_silent_toggle()
    local save_print = print
    print = function() end
    require("shade").toggle()
    print = save_print

    vim.schedule(function()
        -- creates user-defined event to trigger git resolve label redraw
        vim.api.nvim_exec_autocmds("User", {
            pattern = "ShadeToggled",
        })
    end)
end

vim.api.nvim_create_user_command("ShadeOn", function()
    require("shade")

    if not initialized then
        vim.schedule(function()
            shade_silent_toggle()
            shade_silent_toggle()
            shade_active = true
            initialized = true
        end)
        return
    end

    if not shade_active then
        shade_silent_toggle()
        shade_active = true
    end
end, {})

vim.api.nvim_create_user_command("ShadeOff", function()
    require("shade")

    if shade_active then
        shade_silent_toggle()
        shade_active = false
    end
end, {})

vim.api.nvim_create_user_command("ShadeToggle", function()
    require("shade")

    if shade_active then
        vim.cmd("ShadeOff")
    else
        vim.cmd("ShadeOn")
    end
end, {})





local plugins = {
    -- VSCode color theme
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
                    CursorLine = { bg = "#353535" },
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
        ---@diagnostic disable-next-line: undefined-doc-name
        ---@type ibl.config
        opts = {},
    },
    -- notification UI
    {
        "rcarriga/nvim-notify",
        config = function()
            vim.notify = require("notify")
            require("notify").setup({
                timeout = 1000,
                background_colour = "#000000",
            })
        end,
    },
    -- darkens non-focused splits
    {
        "sunjon/shade.nvim",
        lazy = true,
        config = function()
            require("shade").setup({
                overlay_opacity = 25,
                exclude_filetypes = { "neominimap" },
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
        end,
    },
    -- highlights git merge conflict markers
    {
        "spacedentist/resolve.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("resolve").setup({})
            -- use colors to match VSCode theme
            -- some colors blend too much into the terminal colors
            vim.api.nvim_set_hl(0, "ResolveOursMarker", { bg="#36776b", bold=true })
            vim.api.nvim_set_hl(0, "ResolveTheirsMarker", { bg="#2b5d8b", bold=true })
            -- vim.api.nvim_set_hl(0, "ResolveSeparatorMarker", { bg="#242526", bold=true })
            -- vim.api.nvim_set_hl(0, "ResolveAncestorMarker", { bg="#313232", bold=true })
            vim.api.nvim_set_hl(0, "ResolveOursSection", { bg="#1e3833" })
            vim.api.nvim_set_hl(0, "ResolveTheirsSection", { bg="#1d3144" })
            -- vim.api.nvim_set_hl(0, "ResolveAncestorSection", { bg = "#1f1f20" })

            -- setup for adding "Ours" and "Theirs" to git conflict markers
            local ns = vim.api.nvim_create_namespace("conflict_labels")

            local function add_labels(bufnr)
                if not vim.api.nvim_buf_is_valid(bufnr) then return end

                local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

                -- Clear previous labels
                vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

                local total_num_columns = vim.api.nvim_win_get_width(0)
                local column_offset
                if not shade_active then
                    column_offset = math.max(25, total_num_columns-35)
                else
                    column_offset = math.max(25, total_num_columns-15)
                end
                for i, line in ipairs(lines) do
                    if line:match("^<<<<<<<") then
                        vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
                            virt_text = {
                                { "← OURS  ", "ResolveOursMarker" },
                            },
                            virt_text_pos = "overlay",
                            virt_text_win_col = column_offset
                        })
                    elseif line:match("^>>>>>>>") then
                        vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
                            virt_text = {
                                { "← THEIRS", "ResolveTheirsMarker" },
                            },
                            virt_text_pos = "overlay",
                            virt_text_win_col = column_offset
                        })
                    end
                end

                -- silences notifications for conflict detection
                local save_notify = vim.notify
                vim.notify = function() end
                require("resolve").detect_conflicts()
                vim.notify = save_notify
            end

            -- Re-adds the git conflict marker labels after any buffer changes
            vim.api.nvim_create_autocmd(
                {
                    "BufReadPost",
                    "BufNewFile",
                    "BufEnter",
                    "TextChanged",
                    "TextChangedI",
                    "BufWritePost",
                    "VimResized",
                    "WinResized",
                },
                {
                    callback = function(args)
                        add_labels(args.buf)
                    end,
                }
            )

            -- consumes user-defined event to trigger git resolve label redraw
            vim.api.nvim_create_autocmd("User", {
                pattern = "ShadeToggled",
                callback = function(args)
                    add_labels(args.buf)
                end
            })
        end
    },
    -- better syntax highlighting detection
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate'
    },
    -- additional treesitter for text objects
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        init = function()
            -- Disable entire built-in ftplugin mappings to avoid conflicts.
            -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
            vim.g.no_plugin_maps = true

            -- Or, disable per filetype (add as you like)
            -- vim.g.no_python_maps = true
            -- vim.g.no_ruby_maps = true
            -- vim.g.no_rust_maps = true
            -- vim.g.no_go_maps = true
        end,
        config = function()
            -- put your config here
        end,
    },
    ---minimap UI
    {
        "Isrothy/neominimap.nvim",
        version = "v3.x.x",
        lazy = false, -- NOTE: NO NEED to Lazy load
        -- Optional. You can also set your own keybindings
        -- NOTE: In order to have compatibility with shade.nvim, Neominimap can only be on if shade.nvim is off and vice versa
        keys = {
            -- Global Minimap Controls
            { "<leader>mm", "<cmd>Neominimap Toggle<cr><cmd>ShadeToggle<cr>", desc = "Toggle global minimap" },
            { "<leader>mo", "<cmd>Neominimap Enable<cr><cmd>ShadeOff<cr>", desc = "Enable global minimap" },
            { "<leader>mc", "<cmd>Neominimap Disable<cr><cmd>ShadeOn<cr>", desc = "Disable global minimap" },
            { "<leader>mr", "<cmd>Neominimap Refresh<cr>", desc = "Refresh global minimap" },

            -- Window-Specific Minimap Controls
            { "<leader>nwt", "<cmd>Neominimap WinToggle<cr><cmd>ShadeToggle<cr>", desc = "Toggle minimap for current window" },
            { "<leader>nwr", "<cmd>Neominimap WinRefresh<cr>", desc = "Refresh minimap for current window" },
            { "<leader>nwo", "<cmd>Neominimap WinEnable<cr><cmd>ShadeOff<cr>", desc = "Enable minimap for current window" },
            { "<leader>nwc", "<cmd>Neominimap WinDisable<cr><cmd>ShadeOn<cr>", desc = "Disable minimap for current window" },

            -- Tab-Specific Minimap Controls
            { "<leader>ntt", "<cmd>Neominimap TabToggle<cr><cmd>ShadeToggle<cr>", desc = "Toggle minimap for current tab" },
            { "<leader>ntr", "<cmd>Neominimap TabRefresh<cr>", desc = "Refresh minimap for current tab" },
            { "<leader>nto", "<cmd>Neominimap TabEnable<cr><cmd>ShadeOff<cr>", desc = "Enable minimap for current tab" },
            { "<leader>ntc", "<cmd>Neominimap TabDisable<cr><cmd>ShadeOn<cr>", desc = "Disable minimap for current tab" },

            -- Buffer-Specific Minimap Controls
            { "<leader>nbt", "<cmd>Neominimap BufToggle<cr><cmd>ShadeToggle<cr>", desc = "Toggle minimap for current buffer" },
            { "<leader>nbr", "<cmd>Neominimap BufRefresh<cr>", desc = "Refresh minimap for current buffer" },
            { "<leader>nbo", "<cmd>Neominimap BufEnable<cr><cmd>ShadeOff<cr>", desc = "Enable minimap for current buffer" },
            { "<leader>nbc", "<cmd>Neominimap BufDisable<cr><cmd>ShadeOn<cr>", desc = "Disable minimap for current buffer" },

            ---Focus Controls
            { "<leader>nf", "<cmd>Neominimap Focus<cr>", desc = "Focus on minimap" },
            { "<leader>nu", "<cmd>Neominimap Unfocus<cr>", desc = "Unfocus minimap" },
            { "<leader>ns", "<cmd>Neominimap ToggleFocus<cr>", desc = "Switch focus on minimap" },
        },
        init = function()
            -- The following options are recommended when layout == "float"
            vim.opt.wrap = false
            vim.opt.sidescrolloff = 36 -- Set a large value

            --- Put your configuration here
            ---@diagnostic disable-next-line: undefined-doc-name
            ---@type Neominimap.UserConfig
            vim.g.neominimap = {
                auto_enable = true,
            }
        end,
    },
    -- statusline plugin
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local function char_info_under_cursor()
                local _, col = table.unpack(vim.api.nvim_win_get_cursor(0))
                local line = vim.api.nvim_get_current_line()

                if #line == 0 then
                    return string.format(": ASCII N/A  ")
                end

                -- Convert byte index → UTF-8 character index
                local byte_col = col + 1
                local char_idx = vim.fn.charidx(line, byte_col - 1)

                -- Get the UTF-8 character at that position
                local char = vim.fn.strcharpart(line, char_idx, 1)

                if char == "" then
                    return string.format(": ASCII N/A  ")
                end

                -- Get Unicode codepoint
                local codepoint = vim.fn.char2nr(char)

                -- Format output
                if codepoint < 128 then
                    -- if char == " " then char = "(Space)" end
                    -- local extra_space = ""
                    -- if codepoint < 100 then extra_space = " " end
                    -- if codepoint < 10 then extra_space = "  " end
                    return string.format("%8s: ASCII %3d  ", char == " " and "(Space)" or char, codepoint)
                    -- return string.format("%s: ASCII %d" .. extra_space, char, codepoint)
                else
                    -- return string.format("Char: %s (U+%04X)", char, codepoint)
                    return string.format("%s: U+%04X  ", char, codepoint)
                end
            end

            -- local function get_ascii()
            --     local _, col = unpack(vim.api.nvim_win_get_cursor(0))
            --     local line = vim.api.nvim_get_current_line()
            --     local char = line:sub(col+1, col+1)
            --     if char == "" then return "ASCII: N/A" end
            --     return "ASCII: " .. string.byte(char)
            -- end
            require("lualine").setup({
                options = {
                    theme = "wombat",
                },
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            -- remove bold for mode text
                            -- color = { gui = nil },
                        }
                    },
                    lualine_x = {
                        char_info_under_cursor
                    },
                }
            })
            vim.o.showmode = false
        end
    },
    -- scope.nvim for better buffer management
    {
        "tiagovla/scope.nvim",
        config = true,
    },
    -- tabline plugin
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("bufferline").setup({})
        end,
    },
    -- fuzzy file finder
    {
        "nvim-telescope/telescope.nvim",
        version = "*",
        dependencies = {
            "nvim-lua/plenary.nvim",
            -- optional but recommended
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
        end,
    },
    -- sorts telescope files on usage
    {
        "nvim-telescope/telescope-frecency.nvim",
        -- install the latest stable version
        version = "*",
        config = function()
            require("telescope").load_extension "frecency"
        end,
    },
    -- easier way to choose splits
    {
        "s1n7ax/nvim-window-picker",
        name = "window-picker",
        event = "VeryLazy",
        version = "2.*",
        config = function()
            require"window-picker".setup({
                picker_config = {
                    floating_big_letter = {
                        font = "ansi-shadow",
                    },
                },
            })
            vim.keymap.set("n", "<leader>w", function()
                local picker = require("window-picker")
                local win_id = picker.pick_window({ hint="floating-big-letter" })
                if win_id then
                    vim.api.nvim_set_current_win(win_id)
                end
            end, { desc="Launch window picker" })
        end,
    },
    -- highlights occurrences of the word under the cursor
    {
        "RRethy/vim-illuminate",
        config = function()
            require("illuminate").configure({})
        end,
    },
    -- shows context in UI (e.g. file -> class name -> function name)
    {
        "utilyre/barbecue.nvim",
        name = "barbecue",
        version = "*",
        dependencies = {
            "SmiteshP/nvim-navic",
            "nvim-tree/nvim-web-devicons", -- optional dependency
        },
        opts = {
        -- configurations go here
        },
    },
    -- file tree
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons", -- optional, but recommended
        },
        lazy = false, -- neo-tree will lazily load itself
        vim.keymap.set("n", "<leader>e", function()
            require("neo-tree.command").execute({
                toggle = true,
                dir = vim.loop.cwd(),
            })
        end, { desc = "Toggle Neotree" }),
        config = function()
            require("neo-tree").setup({
                default_component_configs = {
                    git_status = {
                        -- enabled = true,
                        enabled = false,
                        symbols = {
                            added     = "A",
                            modified  = "M",
                            deleted   = "D",
                            renamed   = "R",
                            untracked = "?",
                            ignored   = "I",
                            unstaged  = "U",
                            staged    = "S",
                            conflict  = "C",
                        },
                    }
                },
            })
        end,
    },
    -- Git UI
    {
        "NeogitOrg/neogit",
        lazy = true,
        dependencies = {
            "nvim-lua/plenary.nvim",         -- required
            "sindrets/diffview.nvim",        -- optional
            -- For a custom log pager
            "m00qek/baleia.nvim",            -- optional
            "nvim-telescope/telescope.nvim", -- optional
        },
        cmd = "Neogit",
        keys = {
            { "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" }
        },
    },
    -- shows scrollbar and locations of diagnostics
    {
        "dstein64/nvim-scrollview",
        opts = {},
        config=function()
            require("scrollview").setup({
                signs_on_startup = {
                    "diagnostics",
                    "git",
                    "marks",
                    "keywords",
                    "search",
                },
                visibility = "overflow",

                diagnostics_error_symbol = "",
                diagnostics_warn_symbol   = "",
                diagnostics_info_symbol   = "",
                diagnostics_hint_symbol   = "",
            })
            vim.cmd("highlight! ScrollView guifg=#b0b8c4 guibg=#555b66")
        end
    },
    -- Git UI
    -- TODO: figure out keymaps
    {
        "SuperBo/fugit2.nvim",
        opts = {
            width = 70,
            external_diffview = true, -- tell fugit2 to use diffview.nvim instead of builtin implementation.
            libgit2_path = "/opt/homebrew/lib/libgit2.dylib",
        },
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
            "nvim-lua/plenary.nvim",
            {
                "chrisgrieser/nvim-tinygit", -- optional: for Github PR view
                dependencies = { "stevearc/dressing.nvim" }
            },
        },
        cmd = { "Fugit2", "Fugit2Blame", "Fugit2Diff", "Fugit2Graph", "Fugit2Rebase" },
        vim.keymap.set("n", "<leader>F", ":Fugit2<CR>", { desc="Toggle Fugit2" })
    },
    -- Git diff view
    -- TODO: figure out how to use this lmao
    {
        "sindrets/diffview.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        -- lazy, only load diffview by these commands
        cmd = {
        "DiffviewFileHistory", "DiffviewOpen", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewRefresh"
        },
        config = function()
            require("diffview").setup({})
        end,
        vim.keymap.set("n", "<leader>go", ":DiffviewOpen<CR>", { desc="Open Diffview" }),
        vim.keymap.set("n", "<leader>gc", ":DiffviewClose<CR>", { desc="Close Diffview" }),
    },
    -- dim unused vars, funcs, params, etc.
    {
        "zbirenbaum/neodim",
        event = "LspAttach",
        config = function()
            require("neodim").setup({
                hide = {
                    virtual_text = false,
                    signs = false,
                    underline = false,
                }
            })
        end
    },
    -- Smooth scrolling
    {
        "karb94/neoscroll.nvim",
        config = function()
            local neoscroll = require("neoscroll")
            local neoscroll_duration = 0.30
            local final_duration = neoscroll_duration * 850

            local function jk_scroll(dir)
                local count = vim.v.count1 * (dir == "j" and 1 or -1)
                -- don't smooth scroll for single line movements
                if count == 1 or count == -1 then
                    vim.cmd("normal! " .. dir)
                    return
                end
                local topline = vim.fn.line("w0")
                local botline = vim.fn.line("w$")
                local scrolloff = vim.o.scrolloff
                local curline = vim.fn.line(".")
                local target = curline+count
                local should_scroll = false
                if dir == "j" then
                    -- the -3 prevents scrolling for if we pass scrolloff by 1, AKA 1 line movement
                    if target-3 > botline-scrolloff then
                        should_scroll = true
                    end
                else
                    -- the +3 prevents scrolling for if we pass scrolloff by 1, AKA 1 line movement
                    if target+3 < topline+scrolloff then
                        should_scroll = true
                    end
                end
                if should_scroll then
                    neoscroll.scroll(count, { move_cursor=true, duration=final_duration })
                    if dir == "j" then
                        vim.cmd("normal! zb")
                    else
                        vim.cmd("normal! zt")
                    end
                else
                    -- weird edge case that scrolls up one too many lines
                    if count < 0 then
                        count = count+1
                    end
                    vim.cmd("normal! " .. count .. dir)
                end
            end

            neoscroll.setup({
                mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "zt", "zz", "zb"},
                duration_multiplier = neoscroll_duration,
                easing = "quadratic",
            })
            vim.keymap.set("n", "j", function() jk_scroll("j") end, { silent = true })
            vim.keymap.set("n", "k", function() jk_scroll("k") end, { silent = true })
        end
    },
    {
        "luukvbaal/statuscol.nvim",
        config = function()
            require("statuscol").setup({})
        end,
    },
    {
        "johnfrankmorgan/whitespace.nvim",
        config = function ()
            require("whitespace-nvim").setup({
                -- configuration options and their defaults

                -- `highlight` configures which highlight is used to display
                -- trailing whitespace
                highlight = "DiffDelete",

                -- `ignored_filetypes` configures which filetypes to ignore when
                -- displaying trailing whitespace
                ignored_filetypes = { "TelescopePrompt", "Trouble", "help", "dashboard" },

                -- `ignore_terminal` configures whether to ignore terminal buffers
                ignore_terminal = true,

                -- `return_cursor` configures if cursor should return to previous
                -- position after trimming whitespace
                return_cursor = true,
            })

            -- remove trailing whitespace with a keybinding
            vim.keymap.set("n", "<leader>t", require("whitespace-nvim").trim, { desc="Remove all trailing whitespaces" })
        end
    },
    -- Shows context
    {
        "nvim-treesitter/nvim-treesitter-context",
        config = function()
            require("treesitter-context").setup({
                separator = "━",
                max_lines = 5,
            })
            -- for black context line separator
            local function set_separator_hl_group()
                vim.api.nvim_set_hl(0, "TreesitterContextSeparator", {
                    fg = "#000000",
                })
            end
            set_separator_hl_group()
            -- applies hl group in case color scheme loads after this plugin
            vim.api.nvim_create_autocmd("ColorScheme", {
                group = vim.api.nvim_create_augroup("MyTsContextSeparator", { clear=true }),
                callback = set_separator_hl_group,
            })
        end
    },
    -- Shows commit message
    {
        "rhysd/git-messenger.vim",
        config = function()
            vim.g.git_messenger_no_default_mappings = true
            vim.g.git_messenger_conceal_word_diff_marker = false
            vim.g.git_messenger_floating_win_opts = { border="rounded" }
            vim.keymap.set("n", "<leader>gm", ":GitMessenger<CR>", { silent=true, desc="Shows the commit message of the current line" })
        end
    },
    -- Show leading spaces and newlines in visual mode
    {
        "mcauley-penney/visual-whitespace.nvim",
        event = "ModeChanged *:[vV\22]", -- optionally, lazy load on entering visual mode
        -- This can go in your color scheme or in your plugin config
        config = function()
            require("visual-whitespace").setup({
                match_types = {
                    space = false,
                    tab = false,
                    nbsp = false,
                    lead = true,
                    trail = false,
                },
                list_chars = {
                    lead = ".",
                },
                fileformat_chars = {
                    unix = "󰘌",
                    mac = "󰘌",
                    dos = "󰘌",
                }
            })
            vim.api.nvim_set_hl(0, "VisualNonText", { fg = "#5D5F71", bg = "#24282d"})
        end
    },
    -- Git blame viewer
    {
        "FabijanZulj/blame.nvim",
        lazy = false,
        config = function()
            require("blame").setup({})
            vim.keymap.set("n", "<leader>gb", ":BlameToggle<CR>", { silent=true, desc="Toggle Git blame viewer" })
        end,
    },
}


-- TODO: disable plugins that only work for terminal
if vim.g.vscode ~= nil then
    -- only enable UI plugins if we're not in VSCode environment
    for _, plugin in ipairs(plugins) do
        plugin.enabled = false
    end
end

return plugins
