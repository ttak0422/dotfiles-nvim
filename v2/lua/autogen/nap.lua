-- [nfnl] v2/fnl/nap.fnl
local nap = require("nap")
local diagnostic_wrn_options = {severity = {min = vim.diagnostic.severity.WARN}, float = false}
local diagnostic_err_options = {severity = {min = vim.diagnostic.severity.ERROR}, float = false}
local function get_qflist_nr(nr)
  return vim.fn.getqflist({nr = nr}).nr
end
local function safe_qf_colder()
  local idx = get_qflist_nr(0)
  if (1 < idx) then
    return vim.cmd("silent colder")
  else
    return vim.notify("reached start of quickfix list")
  end
end
local function safe_qf_cnewer()
  local idx = get_qflist_nr(0)
  local last_idx = get_qflist_nr("$")
  if (idx < last_idx) then
    return vim.cmd("silent cnewer")
  else
    return vim.notify("reached end of quickfix list")
  end
end
local operators
local function _3_()
  return vim.diagnostic.goto_next(diagnostic_wrn_options)
end
local function _4_()
  return vim.diagnostic.goto_prev(diagnostic_wrn_options)
end
local function _5_()
  return vim.diagnostic.goto_next(diagnostic_err_options)
end
local function _6_()
  return vim.diagnostic.goto_prev(diagnostic_err_options)
end
local function _7_()
  return require("harpoon"):list():next()
end
local function _8_()
  return require("harpoon"):list():next()
end
operators = {b = {next = {opts = {desc = "> buffer"}, rhs = ("<Cmd>" .. "<Cmd>bnext<CR>" .. "<CR>")}, prev = {opts = {desc = "< buffer"}, rhs = ("<Cmd>" .. "<Cmd>bprevious<CR>" .. "<CR>")}}, B = {next = {opts = {desc = "> buffer (history)"}, rhs = ("<Cmd>" .. "<Cmd>BufSurfForward<CR>" .. "<CR>")}, prev = {opts = {desc = "< buffer (history)"}, rhs = ("<Cmd>" .. "<Cmd>BufSurfBack<CR>" .. "<CR>")}}, d = {next = {opts = {desc = "> warning"}, rhs = _3_}, prev = {opts = {desc = "< warning"}, rhs = _4_}}, D = {next = {opts = {desc = "> error"}, rhs = _5_}, prev = {opts = {desc = "< error"}, rhs = _6_}}, e = {next = {opts = {desc = "> edit"}, rhs = "g;"}, prev = {opts = {desc = "< edit"}, rhs = "g,"}}, j = {next = {opts = {desc = "> jump"}, rhs = "<C-i>"}, prev = {opts = {desc = "< jump"}, rhs = "<C-o>"}}, h = {next = {opts = {desc = "> harpoon"}, rhs = _7_}, prev = {opts = {desc = "< harpoon"}, rhs = _8_}}, q = {next = {opts = {desc = "> qf (item)"}, rhs = ("<Cmd>" .. "<Cmd>Qnext<CR>" .. "<CR>")}, prev = {opts = {desc = "< qf (item)"}, rhs = ("<Cmd>" .. "<Cmd>Qprev<CR>" .. "<CR>")}}, ["<C-q>"] = {next = {opts = {desc = "> qf (file)"}, rhs = ("<Cmd>" .. "<Cmd>cnfile<CR>" .. "<CR>")}, prev = {opts = {desc = "< qf (file)"}, rhs = ("<Cmd>" .. "<Cmd>cpfile<CR>" .. "<CR>")}}, ["<M-q>"] = {next = {opts = {desc = "> qf (list)"}, rhs = safe_qf_cnewer}, prev = {opts = {desc = "< qf (list)"}, rhs = safe_qf_colder}}, g = nap.gitsigns()}
return nap.setup({next_prefix = "]", prev_prefix = "[", next_repeat = "<c-n>", prev_repeat = "<c-p>", exclude_default_operators = {"f", "F", "z", "s", "'", "l", "L", "<C-l>", "<M-l>"}, operators = operators})
