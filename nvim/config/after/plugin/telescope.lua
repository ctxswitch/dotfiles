local actions = require "telescope.actions"
local builtin = require('telescope.builtin')

require("telescope").setup {
  pickers = {
    buffers = {
      mappings = {
        i = {
	  -- deletes the buffer, but will give an error if the buffer has unsaved changes.  It
	  -- may be worth wihile to see if we can save the buffer before deleting it.
          ["<c-d>"] = actions.delete_buffer + actions.move_to_top,
        }
      }
    }
  },
  extensions = {
    file_browser = {
      theme = "ivy",
      hijack_netrw = true,
      mappings = {
        i = {},
        n = {},
      },
    },
  },
}

require("telescope").load_extension "file_browser"

vim.keymap.set('n', '<leader>fa', builtin.find_files, {})
vim.keymap.set('n', '<leader>ff', builtin.git_files, {})
vim.keymap.set('n', '<leader>fs', builtin.live_grep, {})
vim.keymap.set('n', '<leader>bb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fr', builtin.lsp_references, {noremap = true, silent = true})
vim.keymap.set('n', '<leader>fb', ':Telescope file_browser<CR>', {noremap = true})
