-- [nfnl] Compiled from fnl/git-conflict.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local M = require("git-conflict")
  M.setup()
end
local _1_ = package.loaded.morimo
if (nil ~= _1_) then
  local morimo = _1_
  if (vim.g.colors_name == "morimo") then
    return morimo.load("git-conflict")
  else
    return nil
  end
else
  return nil
end
