require("toggleterm").setup()

-- Allow escape to toggle back out of the terminal
vim.keymap.set("t", "<esc>", "<C-\\><C-N>", { nowait = true })
vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>:ToggleTerm direction=horizontal<CR>")
vim.keymap.set("n", "<C-\\>", "<cmd> ToggleTerm direction=horizontal<CR>")
vim.keymap.set("n", "<leader>tt", "<cmd> TermExec cmd='make test'<CR>")
vim.keymap.set("n", "<leader>tl", "<cmd> TermExec cmd='make lint'<CR>")

