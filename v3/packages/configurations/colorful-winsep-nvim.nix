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
  plugin = sources.colorful-winsep-nvim;
  config = luaConfig (
    # lua
    ''
      require("colorful-winsep").setup({
        animate = { enabled = false },
        excluded_ft = { "TelescopePrompt" },
        indicator_for_2wins = {
          position = "center",
          symbols = {
            start_left = "", end_left = "",
            start_down = "", end_down = "",
            start_up = "", end_up = "",
            start_right = "", end_right = "",
          },
        },
      })
    ''
  );
}
