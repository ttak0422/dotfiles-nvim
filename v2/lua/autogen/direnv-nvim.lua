-- [nfnl] v2/fnl/direnv-nvim.fnl
return require("direnv").setup({autoload_direnv = true, statusline = {enabled = false}, keybindings = {}, notifications = {level = vim.log.levels.INFO, silent_autoload = false}})
