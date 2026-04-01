-- load general keymaps and option settings
require("nvim_files.general_keymaps")
require("nvim_files.options")

-- load specific keymaps depending on dev environment
if vim.g.vscode then
    require("nvim_files.vscode_keymaps")
else
    require("nvim_files.terminal_keymaps")
end

local autocmd = vim.api.nvim_create_autocmd

-- quick visual feedback for what was just yanked
vim.api.nvim_create_autocmd('TextYankPost', {
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 50,
        })
    end,
})
