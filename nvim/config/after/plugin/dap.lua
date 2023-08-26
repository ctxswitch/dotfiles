require('dap-go').setup()

vim.keymap.set('n', '<leader>do', function()
	require('dap').open()
end)
vim.keymap.set('n', '<leader>dc', function()
	require('dap').close()
end)
vim.keymap.set('n', 'C-b', function()
	require('dap').toggle_breakpoint()
end)

require('dapui').setup()

