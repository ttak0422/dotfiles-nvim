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
  plugin = emptyPlugin "inputPlugins";
  dependPlugins = [
    {
      plugin = Comment-nvim;
      config = luaConfig (
        # lua
        ''
          local Comment = require("Comment")
          return Comment.setup({})
        ''
      );
    }
    {
      plugin = tabout-nvim;
      config = luaConfig (
        # lua
        ''
          local tabout = require("tabout")
          local tabouts = {{open = "'", close = "'"}, {open = "\"", close = "\""}, {open = "`", close = "`"}, {open = "(", close = ")"}, {open = "[", close = "]"}, {open = "{", close = "}"}, {open = "<", close = ">"}}
          return tabout.setup({tabkey = "<Tab>", backwards_tabkey = "<S-Tab>", default_tab = "<C-t>", default_shift_tab = "<C-d>", enable_backwards = true, tabouts = tabouts, act_as_shift_tab = false, act_as_tab = false, completion = false, ignore_beginning = false})
        ''
      );
    }
    {
      plugin = auto-save-nvim;
      config = luaConfig (
        # lua
        ''
          local auto_save = require("auto-save")
          local data = require("auto-save.utils.data")
          local targets = data.set_of({"md", "markdown", "norg", "neorg"})
          local function _1_(buf)
            return (((vim.fn.getbufvar(buf, "&modifiable") == 1) and targets[vim.fn.getbufvar(buf, "&filetype")]) or false)
          end
          return auto_save.setup({events = {"InsertLeave", "TextChanged"}, debounce_delay = 500, condition = _1_})
        ''
      );
    }
    {
      plugin = sources.koe-nvim;
      config = luaConfig (
        # lua
        ''
          local koe = require("koe")
          koe.setup({locale = "ja-JP"})
          return vim.keymap.set({"i", "t"}, "<M-t>", koe.toggle, {silent = true, desc = "koe: dictation toggle"})
        ''
      );
    }
  ];
  doc = "Enabled v2/default inputPlugins configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
