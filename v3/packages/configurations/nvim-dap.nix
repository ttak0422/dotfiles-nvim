{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
with sources;
{
  plugin = sources.nvim-dap;
  config = luaConfig ''
    local dap = require("dap")
    -- Keep the UI open after the debug session ends.
    dap.listeners.before.event_terminated.dapui_config = function() end
    dap.listeners.before.event_exited.dapui_config = function() end
  '';
}
