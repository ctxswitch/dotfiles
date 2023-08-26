vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	use('wbthomason/packer.nvim')
	use('nvim-tree/nvim-tree.lua')
	use('nvim-tree/nvim-web-devicons')
	use('nvim-lualine/lualine.nvim')
	use('mfussenegger/nvim-dap')
	use('mfussenegger/nvim-lint')
	use('tpope/vim-fugitive')
	use('mg979/vim-visual-multi')
	use('leoluz/nvim-dap-go')
	use({'ray-x/go.nvim',
		requires = {
			{'ray-x/guihua.lua'},
			{'neovim/nvim-lspconfig'},
			{'nvim-treesitter/nvim-treesitter'},
		}
	})
	use({
		'catppuccin/nvim',
		as = 'catppuccin'
	})
	use({
		'nvim-telescope/telescope.nvim', tag = '0.1.2',
		requires = { {'nvim-lua/plenary.nvim'} }
	})
	use({
		'nvim-treesitter/nvim-treesitter',
		{run = ':TSUpdate'}
	})
	use {
		"akinsho/toggleterm.nvim",
		tag = '*'
	}
	use {
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v2.x',
		requires = {
			-- LSP Support
			{'neovim/nvim-lspconfig'},             -- Required
			{'williamboman/mason.nvim'},           -- Optional
			{'williamboman/mason-lspconfig.nvim'}, -- Optional

			-- Autocompletion
			{'hrsh7th/nvim-cmp'},     -- Required
			{'hrsh7th/cmp-nvim-lsp'}, -- Required
			{'L3MON4D3/LuaSnip'},     -- Required
		}
	}
	use {
		"rcarriga/nvim-dap-ui",
		requires = {"mfussenegger/nvim-dap"}
	}
end)
