-- [nfnl] v2/fnl/after/ftplugin/Avante.fnl
vim.opt_local.conceallevel = 2
do
  local opts = {buffer = true, silent = true}
  for _, key in ipairs({"i", "a", "o", "A", "I", "O", "s", "S", "c", "C"}) do
    vim.keymap.set("n", key, "<Nop>", opts)
  end
end
vim.cmd("normal! 0")
local function _1_()
  local function _2_()
    return vim.cmd("normal! 0")
  end
  return vim.schedule(_2_)
end
return vim.api.nvim_create_autocmd("WinEnter", {buffer = 0, callback = _1_})
