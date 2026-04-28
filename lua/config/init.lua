-- load general keymaps and option settings
require("config.general_keymaps")
require("config.options")

-- load specific keymaps depending on dev environment
if vim.g.vscode then
    require("config.vscode_keymaps")
else
    require("config.terminal_keymaps")
end
