-- [nfnl] v2/fnl/after/ftplugin/markdown.fnl
for key, value in pairs({signcolumn = "no", foldcolumn = "0", listchars = "tab:> ", virtualedit = "all", number = false}) do
  vim.opt_local[key] = value
end
return nil
