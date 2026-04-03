return {
    -- auto pairing for [{("")}], etc.
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true
        -- use opts = {} for passing setup options
        -- this is equivalent to setup({}) function
    },
    -- comment plugin (in addition to Neovim built-in commenting)
    {
        'numToStr/Comment.nvim',
        opts = {
            -- add any options here
        }
    },
}
