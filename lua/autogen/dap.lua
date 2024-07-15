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
      return (" = " .. variable.value)
    else
      return (variable.name .. " = " .. variable.value)
    end
  end
  display_callback = _3_
  local virt_text_pos
  local function _5_()
    if (vim.fn.has("nvim-0.10") == 1) then
      return "inline"
    else
      return "eol"
    end
  end
  virt_text_pos = _5_()
  M.setup({enabled_commands = true, highlight_changed_variables = true, show_stop_reason = true, commented = true, only_first_definition = true, display_callback = display_callback, virt_text_pos = virt_text_pos, virt_text_win_col = nil, virt_lines = false, all_frames = false, clear_on_continue = false, highlight_new_as_changed = false, enabled = false, all_references = false})
end
local M = require("nvim-dap-repl-highlights")
return M.setup()
