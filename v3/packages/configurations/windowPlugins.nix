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
  plugin = emptyPlugin "windowPlugins";
  dependPlugins = [
    {
      plugin = colorful-winsep-nvim;
      config = luaConfig (
        # lua
        ''
          local winsep = require("colorful-winsep")
          return winsep.setup({animate = {enabled = false}, excluded_ft = {"TelescopePrompt"}, indicator_for_2wins = {position = "center", symbols = {start_left = "", end_left = "", start_down = "", end_down = "", start_up = "", end_up = "", start_right = "", end_right = ""}}})
        ''
      );
    }
    {
      plugin = smart-splits-nvim;
      config = luaConfig (
        # lua
        ''
          local ss = require("smart-splits")
          local ignored_filetypes = {"nofile", "quickfix", "prompt"}
          local ignored_buftypes = {"NvimTree"}
          local ignored_events = {"BufEnter", "WinEnter"}
          return ss.setup({ignored_filetypes = ignored_filetypes, ignored_buftypes = ignored_buftypes, ignored_events = ignored_events})
        ''
      );
    }
    {
      plugin = winresizer;
      preConfig = luaConfig ({
        language = "vim";
        code = ''
          let g:winresizer_start_key = '<C-w>e'
        '';
      });
    }
    {
      plugin = keep-split-ratio-nvim;
      config = luaConfig (
        # lua
        ''
          local split_ratio = require("keep-split-ratio")
          return split_ratio.setup()
        ''
      );
    }
  ];
  config = luaConfig (
    # lua
    ''
      local opts = {noremap = true, silent = true}
      local desc
      local function _1_(d)
        return {noremap = true, silent = true, desc = d}
      end
      desc = _1_
      local function _2_()
        return require("nvim-window").pick()
      end
      for _, k in ipairs({{"<C-w>H", "<Cmd>WinShift left<CR>"}, {"<C-w>J", "<Cmd>WinShift down<CR>"}, {"<C-w>K", "<Cmd>WinShift up<CR>"}, {"<C-w>L", "<Cmd>WinShift right<CR>"}, {"<C-w><C-w>", "<Cmd>WinShift swap<CR>"}, {"<C-w>p", _2_, desc("pick window")}}) do
        vim.keymap.set("n", k[1], k[2], (k[3] or opts))
      end
      return nil
    ''
  );
  doc = "Enabled v2/default windowPlugins configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
