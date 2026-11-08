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
  plugin = toggleterm-nvim;
  dependPlugins = [
    term-gf-nvim
  ];
  config = luaConfig (
    # lua
    ''
      local M = require("toggleterm")
      local size
      local function _1_(term)
        if (term.direction == "horizontal") then
          return (vim.o.lines * 0.5)
        else
          return (vim.o.columns * 0.5)
        end
      end
      size = _1_
      local float_opts
      local function _3_()
        return math.floor((vim.o.columns * 0.95))
      end
      local function _4_()
        return math.floor((vim.o.lines * 0.95))
      end
      float_opts = {border = "single", width = _3_, height = _4_, title_pos = "center"}
      return M.setup({size = size, direction = "float", float_opts = float_opts, start_in_insert = true, winbar = {enabled = false}, auto_scroll = false, shade_terminals = false})
    ''
  );
  doc = "Enabled v2/default toggleterm configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
