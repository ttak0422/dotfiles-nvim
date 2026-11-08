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
  plugin = sources.tabout-nvim;
  config = luaConfig (
    # lua
    ''
      require("tabout").setup({
        tabkey = "<Tab>",
        backwards_tabkey = "<S-Tab>",
        default_tab = "<C-t>",
        default_shift_tab = "<C-d>",
        enable_backwards = true,
        act_as_shift_tab = false,
        act_as_tab = false,
        completion = false,
        ignore_beginning = false,
        tabouts = {
          { open = "'", close = "'" },
          { open = '"', close = '"' },
          { open = "`", close = "`" },
          { open = "(", close = ")" },
          { open = "[", close = "]" },
          { open = "{", close = "}" },
          { open = "<", close = ">" },
        },
      })
    ''
  );
}
