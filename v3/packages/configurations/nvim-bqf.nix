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
  plugin = sources.nvim-bqf;
  config = luaConfig (
    # lua
    ''
      require("bqf").setup({
        func_map = {
          open = "<CR>",
          openc = "o",
          drop = "O",
          split = "<C-s>",
          vsplit = "<C-v>",
          tab = "<C-t>",
          tabb = "",
          tabc = "",
          tabdrop = "",
          ptogglemode = "zp",
          ptoggleitem = "p",
          ptoggleauto = "P",
          pscrollup = "<C-b>",
          pscrolldown = "<C-f>",
          pscrollorig = "zo",
          prevfile = "",
          nextfile = "",
          prevhist = "",
          nexthist = "",
          lastleave = [['"]],
          stoggleup = "<S-Tab>",
          stoggledown = "<Tab>",
          stogglevm = "<Tab>",
          stogglebuf = "'<Tab>",
          sclear = "z<Tab>",
          filter = "zn",
          filterr = "zN",
          fzffilter = "",
        },
      })
    ''
  );
}
