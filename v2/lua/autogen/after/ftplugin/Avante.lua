-- [nfnl] v2/fnl/after/ftplugin/Avante.fnl
vim.opt_local.conceallevel = 2
local opts = {buffer = true, silent = true}
for _, key in ipairs({"i", "a", "o", "A", "I", "O", "s", "S", "c", "C"}) do
  vim.keymap.set("n", key, "<Nop>", opts)
end
return nil
