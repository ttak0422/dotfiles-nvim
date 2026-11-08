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
  plugin = sources.track;
  dependPlugins = [
    definitions.plenary-nvim
    definitions.telescope-nvim
  ];
  extraPackages = with pkgs; [ track-cli ];
  config = luaConfig (
    # lua
    ''
      require("track").setup({ vault_dir = os.getenv("HOME") .. "/track/" })
      require("telescope").load_extension("track")
    ''
  );
}
