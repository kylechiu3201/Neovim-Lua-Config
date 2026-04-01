-- opens the file explorer (project view)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- reload current file
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

-- quickfix and location list navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
