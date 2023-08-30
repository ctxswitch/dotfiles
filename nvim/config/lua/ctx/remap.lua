vim.g.mapleader = " "

vim.keymap.set("i", "{", "{}<Left>")
vim.keymap.set("i", "[", "[]<Left>")
vim.keymap.set("i", "(", "()<Left>")

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move selected line up or down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- Page up and down 1/2 page
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>p", "\"dP")

vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader>w", "<C-w>w")

-- Dap remaps
vim.keymap.set('n', '<leader>do', function()
	require('dap').open()
end)
vim.keymap.set('n', '<leader>dc', function()
	require('dap').close()
end)
vim.keymap.set('n', 'C-b', function()
	require('dap').toggle_breakpoint()
end)

-- Git remaps
vim.keymap.set('n', '<leader>gs', vim.cmd.Git)

-- Nvimtree remaps
vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<CR>")

-- ToggleTerm remaps
vim.keymap.set("t", "<esc>", "<C-\\><C-N>", { nowait = true })
vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>:ToggleTerm direction=horizontal<CR>")
vim.keymap.set("n", "<C-\\>", "<cmd> ToggleTerm direction=horizontal<CR>")
vim.keymap.set("n", "<leader>tt", "<cmd> TermExec cmd='make test'<CR>")
vim.keymap.set("n", "<leader>tl", "<cmd> TermExec cmd='make lint'<CR>")


