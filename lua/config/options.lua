-- turns on absolute and relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- allows undo/redo even after saving/exiting file and ropening
vim.opt.undofile = true

-- ignore casing by default for search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- see substitutions in real time
vim.opt.inccommand = 'split'

-- highlights current line
vim.opt.cursorline = true

-- indentation settings
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- disables GUI cursor styling
vim.opt.guicursor = ""

-- long lines don't wrap to next line
vim.opt.wrap = false

-- turns off backups
-- vim.opt.swapfile = false
-- vim.opt.backup = false

-- enables persistent undo history
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.nvim/undodir"

-- disable search highlighting completely
-- vim.opt.hlsearch = false
-- shows search matches as you type
vim.opt.incsearch = true

-- enables 24-bit colors
vim.opt.termguicolors = true

-- start cursor scrolling further away from edge
vim.opt.scrolloff = 8

-- Puts extra column space on left to make space for markings like git change markings or LSP diagnostic markings
vim.opt.signcolumn = "yes"

-- allows `gf` to work with filenames containing the `@` symbol
vim.opt.isfname:append("@-@")

-- faster update time
vim.opt.updatetime = 50

-- adds a vertical column as a visual guide for keeping lines under a certain length
-- vim.opt.colorcolumn = "80"
