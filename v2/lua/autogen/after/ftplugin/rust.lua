-- [nfnl] v2/fnl/after/ftplugin/rust.fnl
local bufnr = vim.api.nvim_get_current_buf()
local opt = {silent = true, bufnr = bufnr}
local function _1_()
  return vim.cmd.RustLsp({"hover", "actions"})
end
for k, v in pairs({K = _1_}) do
  vim.keymap.set("n", k, v, opt)
end
return nil
