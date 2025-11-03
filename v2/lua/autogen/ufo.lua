-- [nfnl] v2/fnl/ufo.fnl
local ufo = require("ufo")
local provider_selector
local function _1_(bufnr, ft, buftype)
  local case_2_ = {bufnr, ft, buftype}
  local _ = case_2_
  return {"treesitter", "indent"}
end
provider_selector = _1_
ufo.setup({provider_selector = provider_selector})
local opts = {noremap = true, silent = true}
local desc
local function _3_(d)
  return {noremap = true, silent = true, desc = d}
end
desc = _3_
for _, k in ipairs({{"zR", ufo.openAllFolds, desc("\239\145\188 open all folds")}, {"zr", ufo.openFoldsExceptKinds, desc("\239\145\188 open folds")}, {"zM", ufo.closeAllFolds, desc("\239\145\188 close all folds")}, {"zm", ufo.closeAllFolds, desc("\239\145\188 close all folds")}}) do
  vim.keymap.set("n", k[1], k[2], (k[3] or opts))
end
return nil
