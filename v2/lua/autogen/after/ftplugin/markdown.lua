-- [nfnl] v2/fnl/after/ftplugin/markdown.fnl
for key, value in pairs({conceallevel = 2, signcolumn = "no", foldcolumn = "0", number = false}) do
  vim.opt_local[key] = value
end
return nil
