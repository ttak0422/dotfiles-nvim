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
  plugin = sources.ts-error-translator-nvim;
  config = luaConfig (
    # lua
    ''
      require("ts-error-translator").setup({
        auto_attach = true,
        servers = { "astro", "svelte", "ts_ls", "typescript-tools", "volar", "vtsls" },
      })
    ''
  );
}
