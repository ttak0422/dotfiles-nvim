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
  plugin = sources.Ionide-vim;
  preConfig = luaConfig (
    # lua
    ''
      vim.g["fsharp#lsp_recommended_colorscheme"] = 0
      vim.g["fsharp#lsp_codelens"] = 0
    ''
  );
  config = luaConfig (
    # lua
    ''
      vim.lsp.config("ionide", {})
      vim.lsp.enable("ionide")
    ''
  );
  extraPackages = with pkgs; [
    dotnet-sdk_9
    fsautocomplete
  ];
}
