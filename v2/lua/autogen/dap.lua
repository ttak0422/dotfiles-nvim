-- [nfnl] v2/fnl/dap.fnl
local dap = require("dap")
local vscode = require("dap.ext.vscode")
local function _1_()
end
dap.listeners.before.event_terminated["dapui_config"] = _1_
local function _2_()
end
dap.listeners.before.event_exited["dapui_config"] = _2_
vscode.load_launchjs()
local virtual_text = require("nvim-dap-virtual-text")
local function _3_(variable, _buf, _stackframe, _node, _options)
  return (" = " .. variable.value:gsub("%s+", " "))
end
virtual_text.setup({virt_text_pos = "inline", display_callback = _3_})
local dap_repl_highlights = require("nvim-dap-repl-highlights")
return dap_repl_highlights.setup()
