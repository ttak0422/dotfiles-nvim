-- [nfnl] v2/fnl/pre-buffer-plugins-pre.fnl
for k, v in pairs({expandtab = true, tabstop = 2, shiftwidth = 2, showmatch = true, ph = 20, virtualedit = "block"}) do
  vim.o[k] = v
end
return vim.opt.nrformats:append("unsigned")
