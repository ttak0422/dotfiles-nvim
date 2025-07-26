-- [nfnl] v2/fnl/direnv.fnl
for k, v in pairs({direnv_auto = 1, direnv_silent_load = 1}) do
  vim.g[k] = v
end
return nil
