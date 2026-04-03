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
            require("bufferline").setup({
                -- options = {
                --     mode = "buffers", -- set to "tabs" to only show tabpages instead
                --     style_preset = bufferline.style_preset.default, -- or bufferline.style_preset.minimal,
                --     themable = true | false, -- allows highlight groups to be overriden i.e. sets highlights as default
                --     -- numbers = "none" | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
                --     close_command = "bdelete! %d",       -- can be a string | function, | false see "Mouse actions"
                --     right_mouse_command = "bdelete! %d", -- can be a string | function | false, see "Mouse actions"
                --     left_mouse_command = "buffer %d",    -- can be a string | function, | false see "Mouse actions"
                --     middle_mouse_command = nil,          -- can be a string | function, | false see "Mouse actions"
                --     indicator = {
                --         icon = '▎', -- this should be omitted if indicator style is not 'icon'
                --         style = 'icon' | 'underline' | 'none',
                --     },
                --     buffer_close_icon = '󰅖',
                --     modified_icon = '● ',
                --     close_icon = ' ',
                --     left_trunc_marker = ' ',
                --     right_trunc_marker = ' ',
                --     --- name_formatter can be used to change the buffer's label in the bufferline.
                --     --- Please note some names can/will break the
                --     --- bufferline so use this at your discretion knowing that it has
                --     --- some limitations that will *NOT* be fixed.
                --     name_formatter = function(buf)  -- buf contains:
                --           -- name                | str        | the basename of the active file
                --           -- path                | str        | the full path of the active file
                --           -- bufnr               | int        | the number of the active buffer
                --           -- buffers (tabs only) | table(int) | the numbers of the buffers in the tab
                --           -- tabnr (tabs only)   | int        | the "handle" of the tab, can be converted to its ordinal number using: `vim.api.nvim_tabpage_get_number(buf.tabnr)`
                --     end,
                --     max_name_length = 18,
                --     max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
                --     truncate_names = true, -- whether or not tab names should be truncated
                --     tab_size = 18,
                --     diagnostics = false | "nvim_lsp" | "coc",
                --     diagnostics_update_in_insert = false, -- only applies to coc
                --     diagnostics_update_on_event = true, -- use nvim's diagnostic handler
                --     -- The diagnostics indicator can be set to nil to keep the buffer name highlight but delete the highlighting
                --     diagnostics_indicator = function(count, level, diagnostics_dict, context)
                --         return "("..count..")"
                --     end,
                --     -- NOTE: this will be called a lot so don't do any heavy processing here

                --     custom_filter = function(buf_number, buf_numbers)
                --         -- filter out filetypes you don't want to see
                --         if vim.bo[buf_number].filetype ~= "<i-dont-want-to-see-this>" then
                --             return true
                --         end
                --         -- filter out by buffer name
                --         if vim.fn.bufname(buf_number) ~= "<buffer-name-I-dont-want>" then
                --             return true
                --         end
                --         -- filter out based on arbitrary rules
                --         -- e.g. filter out vim wiki buffer from tabline in your work repo
                --         if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
                --             return true
                --         end
                --         -- filter out by it's index number in list (don't show first buffer)
                --         if buf_numbers[1] ~= buf_number then
                --             return true
                --         end
                --     end,
                --     offsets = {
                --         {
                --             filetype = "NvimTree",
                --             text = "File Explorer" | function ,
                --             text_align = "left" | "center" | "right"
                --             separator = true
                --         }
                --     },
                --     color_icons = true | false, -- whether or not to add the filetype icon highlights
                --     get_element_icon = function(element)
                --       -- element consists of {filetype: string, path: string, extension: string, directory: string}
                --       -- This can be used to change how bufferline fetches the icon
                --       -- for an element e.g. a buffer or a tab.
                --       -- e.g.
                --       local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(element.filetype, { default = false })
                --       -- return icon, hl
                --       -- or
                --       local custom_map = {my_thing_ft: {icon = "my_thing_icon", hl}}
                --       return custom_map[element.filetype]
                --     end,
                --     show_buffer_icons = true | false, -- disable filetype icons for buffers
                --     show_buffer_close_icons = true | false,
                --     show_close_icon = true | false,
                --     show_tab_indicators = true | false,
                --     show_duplicate_prefix = true | false, -- whether to show duplicate buffer prefix
                --     duplicates_across_groups = true, -- whether to consider duplicate paths in different groups as duplicates
                --     persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
                --     move_wraps_at_ends = false, -- whether or not the move command "wraps" at the first or last position
                --     -- can also be a table containing 2 custom separators
                --     -- [focused and unfocused]. eg: { '|', '|' }
                --     separator_style = "slant" | "slope" | "thick" | "thin" | { 'any', 'any' },
                --     enforce_regular_tabs = false | true,
                --     always_show_bufferline = true | false,
                --     auto_toggle_bufferline = true | false,
                --     hover = {
                --         enabled = true,
                --         delay = 200,
                --         reveal = {'close'}
                --     },
                --     sort_by = 'insert_after_current' |'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
                --         -- add custom logic
                --         local modified_a = vim.fn.getftime(buffer_a.path)
                --         local modified_b = vim.fn.getftime(buffer_b.path)
                --         return modified_a > modified_b
                --     end,
                --     pick = {
                --       alphabet = "abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ1234567890",
                --     },
                -- }
            })
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
    -- colorizes hex colors like #558817
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup({})
            vim.api.nvim_create_autocmd("BufReadPost", {
                callback = function()
                    vim.cmd("ColorizerAttachToBuffer")
                end,
            })
        end
    }
    --[[ {
        "yorickpeterse/nvim-pqf",
        config = function()
            require("pqf").setup({})
        end,
    }, ]]
}

-- only enable UI plugins if we're not in VSCode environment
for _, plugin in ipairs(plugins) do
    plugin.enabled = should_enable_in_terminal
end

return plugins
