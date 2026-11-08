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
  plugin = sources.csvview-nvim;
  config = luaConfig (
    # lua
    ''
      require("csvview").setup({
        keymaps = {
          textobject_field_inner = { "if", mode = { o = "x" } },
          textobject_field_outer = { "af", mode = { o = "x" } },
          jump_next_field_end = { "<Tab>", mode = { n = "v" } },
          jump_prev_field_end = { "<S-Tab>", mode = { n = "v" } },
          jump_next_row = { "<Enter>", mode = { n = "v" } },
          jump_prev_row = { "<S-Enter>", mode = { n = "v" } },
        },
        view = { display_mode = "border" },
      })
    ''
  );
}
