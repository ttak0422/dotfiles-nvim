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
  plugin = emptyPlugin "cmdlinePlugins";
  dependPlugins = [
    {
      plugin = atone-nvim;
      config = luaConfig (
        # lua
        ''
          local atone = require("atone")
          local layout = {direction = "left", width = 0.25}
          local diff_cur_node = {enabled = true, split_percent = 0.35}
          local keymaps = {tree = {quit = {"<C-c>", "q"}, next_node = "j", pre_node = "k", undo_to = "<CR>", help = {"?", "g?"}}, auto_diff = {quit = {"<C-c>", "q"}, help = {"?", "g?"}}, help = {quit_help = {"<C-c>", "q"}}}
          local ui = {border = "single"}
          return atone.setup({layout = layout, diff_cur_node = diff_cur_node, keymaps = keymaps, ui = ui})
        ''
      );
    }
    {
      plugin = helpview-nvim;
      dependPlugins = [
        devicons
      ];
      config = luaConfig (
        # lua
        ''
          local helpview = require("helpview")
          local preview = {modes = {"n", "c", "no"}}
          local vimdoc = {}
          return helpview.setup({preview = preview, vimdoc = vimdoc})
        ''
      );
    }
    {
      plugin = history-ignore-nvim;
      config = luaConfig (
        # lua
        ''
          local history = require("history-ignore")
          local ignore_words = {"^buf$", "^history$", "^h$", "^q$", "^qa$", "^w$", "^wq$", "^wa$", "^wqa$", "^q!$", "^qa!$", "^w!$", "^wq!$", "^wa!$", "^wqa!$"}
          return history.setup({ignore_words = ignore_words})
        ''
      );
    }
    {
      plugin = mkdir-nvim;
    }
    {
      plugin = vimdoc-ja;
    }
    {
      plugin = inc-rename-nvim;
      config = luaConfig (
        # lua
        ''
          local M = require("inc_rename")
          return M.setup({preview_empty_name = false, save_in_cmdline_history = false, show_message = false})
        ''
      );
    }
  ];
  config = luaConfig (
    ''
            vim.cmd([=[
      cabbrev <expr> r getcmdtype() .. getcmdline() ==# ":r" ? [getchar(), ""][1] .. "%s//g<Left><Left>" : (getcmdline() ==# "'<,'>r" ?  [getchar(), ""][1] .. "s//g<Left><Left>" : "r")
      ]=])
    ''
    # lua
    + ''
      for k, v in pairs({ignorecase = true, smartcase = true, hlsearch = true, incsearch = true}) do
        vim.opt[k] = v
      end
      local opts = {noremap = true, silent = true}
      local desc
      local function _1_(d)
        return {noremap = true, silent = true, desc = d}
      end
      desc = _1_
      local function _2_()
        return vim.cmd("vimgrep //gj %")
      end
      local function _3_()
        return vim.cmd("vimgrepadd //gj %")
      end
      for _, k in ipairs({{"<Leader>/", _2_, desc("register search results to qf")}, {"<Leader>?", _3_, desc("add search results to qf")}}) do
        vim.keymap.set("n", k[1], k[2], (k[3] or opts))
      end
      return nil
    ''
  );
  doc = "Enabled v2/default cmdlinePlugins configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
