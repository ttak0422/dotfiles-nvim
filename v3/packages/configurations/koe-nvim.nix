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
  plugin = sources.koe-nvim;
  config = luaConfig (
    # lua
    ''
      local koe = require("koe")
      koe.setup({ locale = "ja-JP" })
      vim.keymap.set({ "i", "t" }, "<M-t>", koe.toggle, {
        silent = true,
        desc = "koe: dictation toggle",
      })
    ''
  );
}
