-- load general keymaps and option settings
require("config.general_keymaps")
require("config.options")

-- load specific keymaps depending on dev environment
if vim.g.vscode then
    require("config.vscode_keymaps")
else
    require("config.terminal_keymaps")
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
