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
  plugin = sources.atone-nvim;
  config = luaConfig (
    # lua
    ''
      require("atone").setup({
        layout = { direction = "left", width = 0.25 },
        diff_cur_node = { enabled = true, split_percent = 0.35 },
        keymaps = {
          tree = {
            quit = { "<C-c>", "q" },
            next_node = "j",
            pre_node = "k",
            undo_to = "<CR>",
            help = { "?", "g?" },
          },
          auto_diff = { quit = { "<C-c>", "q" }, help = { "?", "g?" } },
          help = { quit_help = { "<C-c>", "q" } },
        },
        ui = { border = "single" },
      })
    ''
  );
}
