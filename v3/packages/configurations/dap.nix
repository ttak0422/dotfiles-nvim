{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  emptyPlugin,
  inputs',
}:
with sources;
with definitions;
{
  plugin = emptyPlugin "dap";
  dependPlugins = [
    treesitter
    nvim-dap
    nvim-dap-virtual-text
    nvim-dap-repl-highlights
  ];
  config = luaConfig (
    # lua
    ''
      local dap = require("dap")
      local function _1_()
      end
      dap.listeners.before.event_terminated.dapui_config = _1_
      local function _2_()
      end
      dap.listeners.before.event_exited.dapui_config = _2_
      local virtual_text = require("nvim-dap-virtual-text")
      local function _3_(variable, _buf, _stackframe, _node, _options)
        return (" = " .. variable.value:gsub("%s+", " "))
      end
      virtual_text.setup({virt_text_pos = "inline", display_callback = _3_})
      local dap_repl_highlights = require("nvim-dap-repl-highlights")
      return dap_repl_highlights.setup()
    ''
  );
  doc = "Enabled v2/default dap configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
