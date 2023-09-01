vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	use('wbthomason/packer.nvim')
	use('nvim-lualine/lualine.nvim')
	use('mfussenegger/nvim-dap')
	use('mfussenegger/nvim-lint')
	use('tpope/vim-fugitive')
	use('mg979/vim-visual-multi')
	use('leoluz/nvim-dap-go')
	use('github/copilot.vim')
	use('neovim/nvim-lspconfig')
	use('hrsh7th/nvim-cmp')
  	use('hrsh7th/cmp-nvim-lsp')
  	use('saadparwaiz1/cmp_luasnip')
	use('L3MON4D3/LuaSnip')
	use({
		"cbochs/grapple.nvim",
		requires = { "nvim-lua/plenary.nvim" },
	})
	-- use({'ray-x/go.nvim',
	-- 	requires = {
	-- 		{'ray-x/guihua.lua'},
	-- 		{'neovim/nvim-lspconfig'},
	-- 		{'nvim-treesitter/nvim-treesitter'},
	-- 	}
	-- })
	use({
		'catppuccin/nvim',
		as = 'catppuccin'
	})
	-- use({
	-- 	'nvim-telescope/telescope.nvim',
	-- 	tag = '0.1.2',
	-- 	requires = {
	-- 		{'nvim-lua/plenary.nvim'}
	-- 	}
	-- })
	use({
		'nvim-telescope/telescope-file-browser.nvim',
		requires = {
			{'nvim-telescope/telescope.nvim'},
			{'nvim-lua/plenary.nvim'}
		}
	})
	use({
		'nvim-treesitter/nvim-treesitter',
		{run = ':TSUpdate'}
	})
	use({
		'rcarriga/nvim-dap-ui',
		requires = {"mfussenegger/nvim-dap"}
	})
end)
