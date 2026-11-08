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
  plugin = sources.toggleterm-nvim;
  dependPlugins = [
    definitions.term-gf-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return vim.o.lines * 0.5
          end
          return vim.o.columns * 0.5
        end,
        direction = "float",
        float_opts = {
          border = "single",
          width = function()
            return math.floor(vim.o.columns * 0.95)
          end,
          height = function()
            return math.floor(vim.o.lines * 0.95)
          end,
          title_pos = "center",
        },
        shade_terminals = false,
        auto_scroll = false,
        start_in_insert = true,
        winbar = { enabled = false },
      })
    ''
  );
}
