-- [nfnl] v2/fnl/pre-buffer-plugins-pre.fnl
for k, v in pairs({expandtab = true, tabstop = 2, shiftwidth = 2, showmatch = true, ph = 20, virtualedit = "block", foldcolumn = "1", foldlevel = 99, foldlevelstart = 99, foldenable = true}) do
  vim.o[k] = v
end
vim.opt.fillchars:append({eob = " ", fold = " ", foldopen = "\226\150\190", foldsep = " ", foldclose = "\226\150\184"})
return vim.opt.nrformats:append("unsigned")
