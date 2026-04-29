-- [nfnl] v2/fnl/after/ftplugin/rust.fnl
local opt = {silent = true, buf = 0}
local function _1_()
  return vim.cmd.RustLsp({"hover", "actions"})
end
for k, v in pairs({K = _1_}) do
  vim.keymap.set("n", k, v, opt)
end
return nil
