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
  plugin = sources.track;
  dependPlugins = [
    plenary
    telescope
  ];
  extraPackages = with pkgs; [ track-cli ];
  config = luaConfig (
    # lua
    ''
      require("track").setup({vault_dir = (os.getenv("HOME") .. "/track/")})
      return require("telescope").load_extension("track")
    ''
  );
  doc = "Enabled v2/default track configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
