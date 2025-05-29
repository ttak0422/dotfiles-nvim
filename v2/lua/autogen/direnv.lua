-- [nfnl] Compiled from v2/fnl/direnv.fnl by https://github.com/Olical/nfnl, do not edit.
for k, v in pairs({direnv_auto = 1, direnv_silent_load = 0}) do
  vim.g[k] = v
end
return nil
