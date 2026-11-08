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
  plugin = sources.open-nvim;
  config = luaConfig (''
    require("open").setup({
      system_open = {
        cmd = "${if pkgs.stdenv.isDarwin then "open" else "xdg-open"}",
        args = {},
      }
    })
  '');
}
