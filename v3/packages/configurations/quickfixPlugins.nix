{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  emptyPlugin,
  inputs',
}:
with sources;
with definitions;
{
  plugin = emptyPlugin "quickfixPlugins";
  dependPlugins = [
    {
      plugin = nvim-bqf;
      config = luaConfig (
        # lua
        ''
          local bqf = require("bqf")
          local func_map = {open = "<CR>", openc = "o", drop = "O", split = "<C-s>", vsplit = "<C-v>", tab = "<C-t>", tabb = "", tabc = "", tabdrop = "", ptogglemode = "zp", ptoggleitem = "p", ptoggleauto = "P", pscrollup = "<C-b>", pscrolldown = "<C-f>", pscrollorig = "zo", prevfile = "", nextfile = "", prevhist = "", nexthist = "", lastleave = "'\"", stoggleup = "<S-Tab>", stoggledown = "<Tab>", stogglevm = "<Tab>", stogglebuf = "'<Tab>", sclear = "z<Tab>", filter = "zn", filterr = "zN", fzffilter = ""}
          return bqf.setup({func_map = func_map})
        ''
      );
    }
    {
      plugin = qf-nvim;
      config = luaConfig (
        # lua
        ''
          local qf = require("qf")
          local opt = {auto_close = true, auto_follow = "prev", auto_follow_limit = 8, follow_slow = true, auto_open = true, auto_resize = true, max_height = 8, min_height = 5, wide = true, focus_open = false, number = false, relativenumber = false, unfocus_close = false}
          return qf.setup({l = opt, c = opt, pretty = true, silent = false})
        ''
      );
    }
    {
      plugin = vim-qfreplace;
    }
  ];
  doc = "Enabled v2/default quickfixPlugins configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
