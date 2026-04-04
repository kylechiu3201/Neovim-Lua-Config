-- commands for toggling shade.nvim, we assume by default it is off (lazy = true)
local shade_active = false
local initialized = false

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
    local shade = require("shade")

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
    local shade = require("shade")

    if shade_active then
        shade_silent_toggle()
        shade_active = false
    end
end, {})

vim.api.nvim_create_user_command("ShadeToggle", function()
    local shade = require("shade")

    if shade_active then
        vim.cmd("ShadeOff")
    else
        vim.cmd("ShadeOn")
    end
end, {})


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



local should_enable_in_terminal = vim.g.vscode == nil

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
        opts = {},
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
        { "<leader>nm", "<cmd>Neominimap Toggle<cr><cmd>ShadeToggle<cr>", desc = "Toggle global minimap" },
        { "<leader>no", "<cmd>Neominimap Enable<cr><cmd>ShadeOff<cr>", desc = "Enable global minimap" },
        { "<leader>nc", "<cmd>Neominimap Disable<cr><cmd>ShadeOn<cr>", desc = "Disable global minimap" },
        { "<leader>nr", "<cmd>Neominimap Refresh<cr>", desc = "Refresh global minimap" },

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
                local _, col = unpack(vim.api.nvim_win_get_cursor(0))
                local line = vim.api.nvim_get_current_line()

                if #line == 0 then
                    return "Char: N/A"
                end

                -- Convert byte index → UTF-8 character index
                local byte_col = col + 1
                local char_idx = vim.fn.charidx(line, byte_col - 1)

                -- Get the UTF-8 character at that position
                local char = vim.fn.strcharpart(line, char_idx, 1)

                if char == "" then
                    return "Char: N/A"
                end

                -- Get Unicode codepoint
                local codepoint = vim.fn.char2nr(char)

                -- Format output
                if codepoint < 128 then
                    if char == " " then char = "(Space)" end
                    return string.format("Char: %s (ASCII %d)", char, codepoint)
                else
                    return string.format("Char: %s (U+%04X)", char, codepoint)
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
                    lualine_c = {
                        char_info_under_cursor
                    }
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
    {
        "nvim-telescope/telescope-frecency.nvim",
        -- install the latest stable version
        version = "*",
        config = function()
            require("telescope").load_extension "frecency"
        end,
    },
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
}

-- only enable UI plugins if we're not in VSCode environment
for _, plugin in ipairs(plugins) do
    plugin.enabled = should_enable_in_terminal
end

return plugins
