vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Remap directional keys for normal and visual... Not a fan of the original
-- mappings.
vim.keymap.set("n", "j", "<UP>")
vim.keymap.set("n", "k", "<DOWN>")
vim.keymap.set("n", "l", "<LEFT>")
vim.keymap.set("n", ";", "<RIGHT>")
vim.keymap.set("n", "<C-l>", "<Home>")
vim.keymap.set("n", "<C-;>", "<End>")
vim.keymap.set("v", "j", "<UP>")
vim.keymap.set("v", "k", "<DOWN>")
vim.keymap.set("v", "l", "<LEFT>")
vim.keymap.set("v", ";", "<RIGHT>")
vim.keymap.set("v", "<C-l>", "<Home>")
vim.keymap.set("v", "<C-;>", "<End>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

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

-- This is interesting.  Figure out how pg uses it.
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")


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

-- Telescope remaps
vim.keymap.set('n', '<leader>pf', require('telescope.builtin').find_files, {})
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, {})
vim.keymap.set('n', '<leader>ff', function()
	require('telescope.builtin').grep_string({ search = vim.fn.input("search> ") });
end)

-- ToggleTerm remaps
vim.keymap.set("t", "<esc>", "<C-\\><C-N>", { nowait = true })
vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>:ToggleTerm direction=horizontal<CR>")
vim.keymap.set("n", "<C-\\>", "<cmd> ToggleTerm direction=horizontal<CR>")
vim.keymap.set("n", "<leader>tt", "<cmd> TermExec cmd='make test'<CR>")
vim.keymap.set("n", "<leader>tl", "<cmd> TermExec cmd='make lint'<CR>")


