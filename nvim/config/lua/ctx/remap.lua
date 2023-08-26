vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Remap directional keys for normal and visual... Not a fan of the original
-- mappings.
vim.keymap.set("n", "j", "<UP>")
vim.keymap.set("n", "k", "<DOWN>")
vim.keymap.set("n", "l", "<LEFT>")
vim.keymap.set("n", ";", "<RIGHT>")
vim.keymap.set("n", "<C-j>", "<PageUp>")
vim.keymap.set("n", "<C-k>", "<PageDown>")
vim.keymap.set("n", "<C-l>", "<Home>")
vim.keymap.set("n", "<C-;>", "<End>")

vim.keymap.set("v", "j", "<UP>")
vim.keymap.set("v", "k", "<DOWN>")
vim.keymap.set("v", "l", "<LEFT>")
vim.keymap.set("v", ";", "<RIGHT>")
vim.keymap.set("v", "<C-j>", "<PageUp>")
vim.keymap.set("v", "<C-k>", "<PageDown>")
vim.keymap.set("v", "<C-l>", "<Home>")
vim.keymap.set("v", "<C-;>", "<End>")
