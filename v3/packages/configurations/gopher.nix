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
  plugin = gopher-nvim;
  dependPlugins = [
    {
      plugin = goplements-nvim;
      config = luaConfig (
        # lua
        ''
          local goplements = require("goplements")
          return goplements.setup()
        ''
      );
    }
    {
      plugin = go-impl-nvim;
      dependPlugins = [
        nui
        snacks
      ];
      config = luaConfig (
        # lua
        ''
          local impl = require("go-impl")
          local icons = {interface = {text = "\239\131\168 ", hl = "GoImplInterfaceIcon"}, go = {text = "\238\152\167 ", hl = "GoImplGoBlue"}}
          local prompt = {receiver = "\243\176\134\188 \239\145\160 ", interface = "\239\131\168 \239\145\160 ", generic = "\243\176\152\187  {name}\239\145\160 "}
          return impl.setup({picker = "snacks", icons = icons, prompt = prompt})
        ''
      );
    }
  ];
  config = luaConfig (
    # lua
    ''
      local gopher = require("gopher")
      return gopher.setup()
    ''
  );
  extraPackages = with pkgs; [
    go
    gomodifytags
    gotests
    iferr
    impl
  ];
  doc = "Enabled v2/default gopher configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
