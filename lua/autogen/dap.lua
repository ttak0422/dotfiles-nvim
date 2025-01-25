-- [nfnl] Compiled from fnl/dap.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local dap = setmetatable({vscode = require("dap.ext.vscode")}, {__index = require("dap")})
  local function _1_()
  end
  dap.listeners.before.event_terminated["dapui_config"] = _1_
  local function _2_()
  end
  dap.listeners.before.event_exited["dapui_config"] = _2_
  dap.vscode.load_launchjs()
end
do
  local M = require("nvim-dap-virtual-text")
  local display_callback
  local function _3_(variable, _buf, _stackframe, _node, options)
    if (options.virt_text_pos == "inline") then
      return (" = " .. variable.value:gsub("%s+", " "))
    else
      return (variable.name .. " = " .. variable.value:gsub("%s+", " "))
    end
  end
  display_callback = _3_
  local virt_text_pos = "inline"
  M.setup({enabled = true, enabled_commands = true, highlight_changed_variables = true, show_stop_reason = true, only_first_definition = true, display_callback = display_callback, virt_text_pos = virt_text_pos, virt_text_win_col = nil, all_frames = false, all_references = false, clear_on_continue = false, commented = false, highlight_new_as_changed = false, virt_lines = false})
end
do
  local colors = require("morimo.colors")
  local highlights = {{"dapblue", colors.lightBlue}, {"dapgreen", colors.lightGreen}, {"dapyellow", colors.lightYellow}, {"daporange", colors.orange}, {"dapred", colors.lightRed}}
  local signs = {{"DapBreakpoint", "\239\128\164", "dapblue"}, {"DapBreakpointCondition", "\239\128\164", "dapblue"}, {"DapBreakpointRejected", "\239\134\146", "dapred"}, {"DapStopped", "\226\150\182", "dapgreen"}, {"DapLogPoint", "\239\134\146", "dapyellow"}}
  for _, h in ipairs(highlights) do
    vim.api.nvim_set_hl(0, h[1], {fg = h[2], bg = "none"})
  end
  for _, s in ipairs(signs) do
    vim.fn.sign_define(s[1], {text = s[2], texthl = s[3], linehl = "", numhl = ""})
  end
end
local M = require("nvim-dap-repl-highlights")
return M.setup()
