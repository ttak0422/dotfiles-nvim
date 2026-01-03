-- [nfnl] v2/fnl/rustowl.fnl
local rustowl = require("rustowl")
local on_attach
local function _1_(_, buffer)
  local function _2_()
    return rustowl.toggle(buffer)
  end
  return vim.keymap.set("n", "<LocalLeader>to", _2_, {buffer = buffer, desc = "Toggle RustOwl"})
end
on_attach = _1_
return rustowl.setup({auto_attach = true, idle_time = 1000, highlight_style = "underline", client = {on_attach = on_attach}, auto_enable = false})
