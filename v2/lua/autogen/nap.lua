-- [nfnl] Compiled from v2/fnl/nap.fnl by https://github.com/Olical/nfnl, do not edit.
local nap = require("nap")
local cmd
local function _1_(c)
  return ("<cmd>" .. c .. "<cr>")
end
cmd = _1_
return nap.setup({next_prefix = "]", prev_prefix = "[", next_repeat = "<c-n>", prev_repeat = "<c-p>", exclude_default_operators = {"f", "F", "z", "s", "'", "l", "L", "<C-l>", "<M-l>"}, operators = {b = {prev = {rhs = cmd("bprevious"), opts = {desc = "\226\134\144 buffer"}}, next = {rhs = cmd("bnext"), opts = {desc = "\226\134\146 buffer"}}}, B = {prev = {rhs = cmd("BufSurfBack"), opts = {desc = "\226\134\144 buffer \238\170\130"}}, next = {rhs = cmd("BufSurfForward"), opts = {desc = "\226\134\146 buffer \238\170\130"}}}}})
