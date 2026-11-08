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
  plugin = sources.go-impl-nvim;
  dependPlugins = [
    definitions.nui-nvim
    definitions.snacks-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("go-impl").setup({
        picker = "snacks",
        icons = {
          interface = { text = " ", hl = "GoImplInterfaceIcon" },
          go = { text = " ", hl = "GoImplGoBlue" },
        },
        prompt = {
          receiver = "󰆼  ",
          interface = "  ",
          generic = "󰘻  {name} ",
        },
      })
    ''
  );
}
