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
  plugin = sources.tiny-code-action-nvim.overrideAttrs {
    runtimeDeps = with pkgs; [ delta ];
  };
  dependPlugins = [ definitions.telescope-nvim ];
  config = luaConfig (
    # lua
    ''
      require("tiny-code-action").setup({
        backend = "delta",
        picker = { "telescope", opts = { winborder = "single" } },
      })
    ''
  );
}
