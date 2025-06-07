-- [nfnl] v2/fnl/buffer-plugins.fnl
local cachedir = vim.fn.stdpath("cache")
for k, v in pairs({updatetime = 100, hidden = true, autoread = true, undofile = true, undodir = (cachedir .. "/undo"), swapfile = true, directory = (cachedir .. "/swap"), backup = true, backupcopy = "yes", backupdir = (cachedir .. "/backup"), listchars = "tab:> ,trail:-", list = true, equalalways = false, startofline = false}) do
  vim.opt[k] = v
end
local opts = {noremap = true, silent = true}
local desc
local function _1_(d)
  return {noremap = true, silent = true, desc = d}
end
desc = _1_
local toggle
local function _2_(id)
  local function _3_()
    return require("toggler").toggle(id)
  end
  return _3_
end
toggle = _2_
local function _4_()
  return require("open").open_cword()
end
local function _5_()
  return require("dap").toggle_breakpoint()
end
local function _6_()
  return require("dap").repl.toggle()
end
local function _7_()
  return require("dap").run_last()
end
for _, k in ipairs({{"<Leader>tz", "<Cmd>NeoZoomToggle<CR>", desc("\239\136\132 zoom")}, {"<Leader>U", "<Cmd>UndotreeToggle<CR>", desc("\239\136\132 undotree")}, {"gx", _4_, desc("open")}, {"<LocalLeader>db", _5_, desc("\238\171\152 breakpoint")}, {"<LocalLeader>dr", _6_, desc("\238\171\152 repl")}, {"<LocalLeader>dl", _7_, desc("\238\171\152 run last")}, {"<LocalLeader>dd", toggle("dapui"), desc("\238\171\152 run last")}}) do
  vim.keymap.set("n", k[1], k[2], (k[3] or opts))
end
return nil
