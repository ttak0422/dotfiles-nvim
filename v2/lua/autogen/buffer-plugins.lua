-- [nfnl] v2/fnl/buffer-plugins.fnl
local opts = {noremap = true, silent = true}
local desc
local function _1_(d)
  return {noremap = true, silent = true, desc = d}
end
desc = _1_
for _, k in ipairs({{"<Leader>U", "<Cmd>UndotreeToggle<CR>", desc("\239\136\132 undotree")}}) do
  vim.keymap.set("n", k[1], k[2], (k[3] or opts))
end
return nil
