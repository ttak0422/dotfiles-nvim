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
  plugin = sources.history-ignore-nvim;
  config = luaConfig (
    # lua
    ''
      require("history-ignore").setup({
        ignore_words = {
          "^buf$", "^history$", "^h$",
          "^q$", "^qa$", "^w$", "^wq$", "^wa$", "^wqa$",
          "^q!$", "^qa!$", "^w!$", "^wq!$", "^wa!$", "^wqa!$",
        },
      })
    ''
  );
}
