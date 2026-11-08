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
  plugin = sources.trim-nvim;
  config = luaConfig (
    # lua
    ''
      require("trim").setup({ ft_blocklist = { "markdown", "neorg", "norg" } })
    ''
  );
}
