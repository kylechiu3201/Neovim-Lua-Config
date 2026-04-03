-- setting leader in this file so we don't have to worry about loading order
vim.g.mapleader = " "

-- typical beginning/end of line movement
vim.keymap.set({ "n", "v" }, "H", "^")
vim.keymap.set({ "n", "v" }, "L", "$")

-- faster escape
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "kj", "<Esc>")

-- moves a highlighted selection up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc="Move visual selection up" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc="Move visual selection down" })

-- joins the line without moving cursor (corrupts z mark register)
vim.keymap.set("n", "J", "mzJ`z")

-- scroll with centering
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- turns off highlight for search
-- vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc="Turn off search highlighting" })

-- next/prev with centering/unfolding
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- NOTE THAT BEHAVIOR IS DIFFERENT FOR NORMAL VS VISUAL MODE
-- paste from clipboard
-- TODO: Maybe find better keymap here later
vim.keymap.set("n", "<leader>p", "\"+p", { desc="Paste from clipboard" })
-- pastes without corrupting current yank
vim.keymap.set("x", "<leader>p", [["_dP]], { desc="Paste without corrupting yank" })

-- yank to clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc="Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc="Yank current line to clipboard" })

-- delete without corrupting current yank
vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d", { desc="Delete without corrupting yank" })
vim.keymap.set({ "n", "v" }, "<leader>D", "\"_D", { desc="Delete line without corrupting yank" })

-- visual select last paste
vim.keymap.set("n", "<leader>v", "`[v`]", { desc="Visual select the last paste" })
