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
  plugin = sources.garbage-day-nvim;
  config = luaConfig (
    # lua
    ''
      require("garbage-day").setup({
        excluded_lsp_clients = { "jdtls" },
        grace_period = 60 * 30,
        wakeup_delay = 500,
      })
    ''
  );
}
