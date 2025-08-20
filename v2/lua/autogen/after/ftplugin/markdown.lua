-- [nfnl] v2/fnl/after/ftplugin/markdown.fnl
for key, value in pairs({signcolumn = "no", foldcolumn = "0", listchars = "tab:> ", virtualedit = "all", number = false}) do
  vim.opt_local[key] = value
end
for lhs, rhs in pairs({["<LocalLeader>r"] = "<Cmd>Obsidian backlinks<CR>", ["<LocalLeader>t"] = "<Cmd>Obsidian toggle_checkbox<CR>"}) do
  vim.keymap.set("n", lhs, rhs, {buffer = true})
end
return nil
