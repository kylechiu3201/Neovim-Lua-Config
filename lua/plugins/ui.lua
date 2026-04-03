-- commands for toggling shade.nvim, we assume by default it is off (lazy = true)
local shade_active = false
local initialized = false

local function shade_silent_toggle()
    local save_print = print
    print = function() end
    require("shade").toggle()
    print = save_print
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

    require("resolve").detect_conflicts()
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



local should_enable_in_terminal = vim.g.vscode == nil

local plugins = {
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
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate'
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
}

-- only enable UI plugins if we're not in VSCode environment
for _, plugin in ipairs(plugins) do
    plugin.enabled = should_enable_in_terminal
end

return plugins
