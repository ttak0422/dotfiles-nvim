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
  plugin = sources.videre-nvim;
  dependPlugins = [
    definitions.graph_view_yaml_parser
    definitions.graph_view_toml_parser
  ];
  config = luaConfig (
    # lua
    ''
      require("videre").setup({ editor_type = "floating", box_style = "sharp" })
    ''
  );
}
