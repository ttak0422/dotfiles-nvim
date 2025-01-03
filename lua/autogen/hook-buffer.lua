-- [nfnl] Compiled from fnl/hook-buffer.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local cachePath = vim.fn.stdpath("cache")
  local opts = {mouse = "a", hidden = true, autoread = true, undofile = true, undodir = (cachePath .. "/undo"), swapfile = true, directory = (cachePath .. "/swap"), backup = true, backupcopy = "yes", backupdir = (cachePath .. "/backup"), diffopt = "internal,filler,closeoff,vertical", splitright = true, splitbelow = true, winwidth = 20, winheight = 1, equalalways = false, startofline = false}
  for k, v in pairs(opts) do
    vim.o[k] = v
  end
  vim.opt.fillchars:append({eob = " ", fold = " ", foldopen = "\226\150\190", foldsep = " ", foldclose = "\226\150\184"})
end
local opts = {noremap = true, silent = true}
local desc
local function _1_(d)
  return {noremap = true, silent = true, desc = d}
end
desc = _1_
local cmd
local function _2_(c)
  return ("<cmd>" .. c .. "<cr>")
end
cmd = _2_
local lcmd
local function _3_(c)
  return cmd(("lua " .. c))
end
lcmd = _3_
local function _4_()
  local dap = require("dap")
  return dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end
for _, k in ipairs({{"gpd", lcmd("require('goto-preview').goto_preview_definition()"), desc("preview definition")}, {"gpi", lcmd("require('goto-preview').goto_preview_implementation()"), desc("preview implementation")}, {"gpr", lcmd("require('goto-preview').goto_preview_references()"), desc("preview references")}, {"gP", lcmd("require('goto-preview').close_all_win()"), desc("close all preview")}, {"gb", lcmd("require('dropbar.api').pick()"), desc("pick")}, {"<F5>", lcmd("require('dap').continue()"), desc("continue")}, {"<F10>", lcmd("require('dap').step_over()"), desc("step over")}, {"<F11>", lcmd("require('dap').step_into()"), desc("step into")}, {"<F12>", lcmd("require('dap').step_out()"), desc("step out")}, {"<LocalLeader>db", lcmd("require('dap').toggle_breakpoint()"), desc("dap toggle breakpoint")}, {"<LocalLeader>dB", _4_, desc("dap set breakpoint with condition")}, {"<LocalLeader>dr", lcmd("require('dap').repl.toggle()"), desc("dap toggle repl")}, {"<LocalLeader>dl", lcmd("require('dap').run_last()"), desc("dap run last")}, {"<LocalLeader>dd", cmd("ToggleDapUI"), desc("dap toggle ui")}, {"<Leader>ta", cmd("CopilotChatToggle")}, {"<Leader>O", cmd("Other")}}) do
  vim.keymap.set("n", k[1], k[2], (k[3] or opts))
end
for _, k in ipairs({{"T", cmd("Translate JA")}, {"<LocalLeader>K", lcmd("require('dapui').eval()"), desc("dap evaluate expression")}, {"<Leader>ta", cmd("CopilotChat")}}) do
  vim.keymap.set("v", k[1], k[2], (k[3] or opts))
end
for _, k in ipairs({{"tT", cmd("Neotest")}, {"tt", cmd("NeotestNearest")}, {"to", cmd("NeotestToggleSummary")}, {"tO", cmd("NeotestTogglePanel")}, {"tK", cmd("NeotestOpenOutput")}}) do
  vim.keymap.set("n", ("<LocalLeader>" .. k[1]), k[2], (k[3] or opts))
end
for _, k in ipairs({{{"n", "x"}, "gs", lcmd("require('reacher').start()")}, {{"n", "x"}, "gS", lcmd("require('reacher').start_multiple()"), desc("search displayed")}, {{"n", "i", "c", "t"}, "\194\165", "\\"}}) do
  vim.keymap.set(k[1], k[2], k[3], (k[4] or opts))
end
return nil
