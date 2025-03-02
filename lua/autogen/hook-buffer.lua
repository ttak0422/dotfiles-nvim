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
for _, k in ipairs({{"gpd", lcmd("require('goto-preview').goto_preview_definition()"), desc("\243\176\169\138 definition")}, {"gpi", lcmd("require('goto-preview').goto_preview_implementation()"), desc("\243\176\169\138 implementation")}, {"gpr", lcmd("require('goto-preview').goto_preview_references()"), desc("\243\176\169\138 references")}, {"gP", lcmd("require('goto-preview').close_all_win()"), desc("\243\176\169\138 close all")}, {"gb", lcmd("require('dropbar.api').pick()"), desc("pick")}, {"<F5>", lcmd("require('dap').continue()"), desc("\238\171\152 continue")}, {"<F10>", lcmd("require('dap').step_over()"), desc("\238\171\152 step over")}, {"<F11>", lcmd("require('dap').step_into()"), desc("\238\171\152 step into")}, {"<F12>", lcmd("require('dap').step_out()"), desc("\238\171\152 step out")}, {"<LocalLeader>db", lcmd("require('dap').toggle_breakpoint()"), desc("\238\171\152 toggle breakpoint")}, {"<LocalLeader>dB", _4_, desc("\238\171\152 set breakpoint with condition")}, {"<LocalLeader>dr", lcmd("require('dap').repl.toggle()"), desc("\238\171\152 toggle repl")}, {"<LocalLeader>dl", lcmd("require('dap').run_last()"), desc("\238\171\152 run last")}, {"<LocalLeader>dd", cmd("ToggleDapUI"), desc("\238\171\152 toggle ui")}, {"<Leader>O", cmd("Other")}}) do
  vim.keymap.set("n", k[1], k[2], (k[3] or opts))
end
for _, k in ipairs({{"T", cmd("Translate JA")}, {"<LocalLeader>K", lcmd("require('dapui').eval()"), desc("dap evaluate expression")}, {"<Leader>ta", cmd("CopilotChat")}}) do
  vim.keymap.set("v", k[1], k[2], (k[3] or opts))
end
for _, k in ipairs({{"tT", cmd("Neotest"), desc("\238\169\185 run test (file)")}, {"tt", cmd("NeotestNearest"), desc("\238\169\185 run test (unit)")}, {"to", cmd("NeotestTogglePanel"), desc("\238\169\185 show test results")}, {"tO", cmd("NeotestToggleSummary"), desc("\238\169\185 show test tree")}, {"tK", cmd("NeotestOpenOutput"), desc("\238\169\185 hover (test)")}}) do
  vim.keymap.set("n", ("<LocalLeader>" .. k[1]), k[2], (k[3] or opts))
end
for _, k in ipairs({{{"n", "x"}, "gs", lcmd("require('reacher').start()"), desc("\238\169\173 search (window)")}, {{"n", "x"}, "gS", lcmd("require('reacher').start_multiple()"), desc("\238\169\173 search (editor)")}}) do
  vim.keymap.set(k[1], k[2], k[3], (k[4] or opts))
end
return nil
