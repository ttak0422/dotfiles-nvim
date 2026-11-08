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
  plugin = sources.nginx-vim.overrideAttrs (_: {
    src = pkgs.nix-filter {
      root = sources.nginx-vim.src;
      exclude = [ "ftdetect/nginx.vim" ];
    };
  });
}
