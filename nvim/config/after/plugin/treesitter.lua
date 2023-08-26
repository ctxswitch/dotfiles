require('nvim-treesitter.configs').setup {
	ensure_installed = {
		"bash",
		"css",
		"dockerfile",
		"hcl",
		"html",
		"java",
		"markdown",
		"markdown_inline",
		"regex",
		"yaml",
		"go",
		"rust",
		"c",
		"lua",
		"vim",
		"vimdoc",
		"query",
		"javascript",
		"typescript",
		"python"
	},
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
}

