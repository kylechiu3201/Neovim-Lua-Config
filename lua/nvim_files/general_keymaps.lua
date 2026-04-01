-- setting leader in this file so we don't have to worry about loading order
vim.g.mapleader = " "

-- typical beginning/end of line movement
vim.keymap.set('n', 'H', '^')
vim.keymap.set('n', 'L', '$')

-- faster escape
vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('i', 'kj', '<Esc>')

-- moves a highlighted selection up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- joins the line without moving cursor (corrupts z mark register)
vim.keymap.set("n", "J", "mzJ`z")

-- scroll with centering
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- turns off highlight for search
-- vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>h', '<cmd>nohlsearch<CR>')

-- next/prev with centering/unfolding
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- pastes without corrupting current yank
vim.keymap.set("x", "<leader>p", [["_dP]])

-- yank to clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- delete without corrupting current yank
vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d")
