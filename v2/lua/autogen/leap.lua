-- [nfnl] v2/fnl/leap.fnl
local spooky = require("leap-spooky")
for modes, _1_ in pairs({[{"n", "x", "o"}] = {"s", "<Plug>(leap)", "Leap"}, n = {"S", "<Plug>(leap-from-window)", "Leap from window"}}) do
  local lhs = _1_[1]
  local rhs = _1_[2]
  local desc = _1_[3]
  vim.keymap.set(modes, lhs, rhs, {noremap = true, silent = true, desc = desc})
end
return spooky.setup({})
