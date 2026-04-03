-- opens the file explorer (project view)
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open project view" })

-- reload current file
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

-- quickfix and location list navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc="Go to the previous item in the quickfix list" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc="Go to the next item in the quickfix list" })
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc="Go to the previous item in location list" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc="Go to the next item in location list" })
