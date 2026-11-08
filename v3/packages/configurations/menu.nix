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
  plugin = sources.menu;
  dependPlugins = [
    definitions.volt
  ];
  config = luaConfig (
    # lua
    ''
      local menu = require("menu")
      local items = {
        { hl = "Normal", name = " Toggle NoNeckPain", cmd = "NoNeckPain" },
        {
          hl = "Normal",
          name = " Toggle List",
          cmd = function() vim.o.list = not vim.o.list end,
        },
        { hl = "Normal", name = " Toggle colorize", cmd = "ColorizerToggle" },
        { hl = "Normal", name = " Edit local config", cmd = "ConfigLocalEdit" },
        { hl = "Normal", name = "󰞷 Open scratch buffer", cmd = "RepluaOpen" },
        { name = "separator" },
        { hl = "Normal", name = "󰄉 Timer", cmd = function() vim.cmd.TimerlyToggle() end },
        { hl = "Normal", name = " Show keys", cmd = function() vim.cmd.ShowkeysToggle() end },
        { hl = "Normal", name = " Color Picker", cmd = function() vim.cmd.Huefy() end },
      }
      vim.api.nvim_create_user_command("OpenMenu", function()
        menu.open(items, { border = true })
      end, {})
    ''
  );
}
