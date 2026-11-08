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
  plugin = sources.logrotate-nvim;
  config = luaConfig (
    # lua
    ''
      require("logrotate").setup({
        targets = { vim.fn.stdpath("state") .. "/lsp.log" },
        interval = "daily",
      })
    ''
  );
}
