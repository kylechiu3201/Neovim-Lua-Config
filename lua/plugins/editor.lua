-- setup for adding "Ours" and "Theirs" to git conflict markers
local ns = vim.api.nvim_create_namespace("conflict_labels")

local function add_labels(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then return end

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    -- Clear previous labels
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    for i, line in ipairs(lines) do
        if line:match("^<<<<<<<") then
            vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
                virt_text = {
                    -- { "← OURS  ", "ConflictOurs" },
                    { "← OURS  ", "ResolveOursMarker" },
                },
                virt_text_pos = "right_align",
            })
        elseif line:match("^>>>>>>>") then
            vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
                virt_text = {
                    -- { "← THEIRS", "ConflictTheirs" },
                    { "← THEIRS", "ResolveTheirsMarker" },
                },
                virt_text_pos = "right_align",
            })
        end
    end
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
    },
    {
        callback = function(args)
            add_labels(args.buf)
        end,
    }
)



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
        end,
    },
    -- highlights git merge conflict markers
    {
        "spacedentist/resolve.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {},
    },
}
