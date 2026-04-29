-- [nfnl] v2/fnl/after/ftplugin/yaml.fnl
vim.opt_local.iskeyword:append("-")
return vim.keymap.set("n", "<LocalLeader>E", "<CMD>Videre<CR>", {buf = 0, silent = true})
