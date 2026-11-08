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
  plugin = pkgs.vimPlugins.rustaceanvim.overrideAttrs {
    runtimeDeps = with pkgs; [
      rust-analyzer-unwrapped
    ];
  };
  config = luaConfig (
    # lua
    ''
      local default_settings = {["rust-analyzer"] = {files = {excludeDirs = {".direnv", ".git", ".venv", "bin", "node_modules", "target"}}}}
      vim.g.rustaceanvim = {server = {default_settings = default_settings}}
      return nil
    ''
  );
  doc = "Enabled v2/default rustaceanvim configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
