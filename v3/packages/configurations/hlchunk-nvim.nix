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
  plugin = sources.hlchunk-nvim;
  dependPlugins = [ definitions.sorairo ];
  config = luaConfig (
    # lua
    ''
      require("hlchunk").setup({
        indent = { enable = false },
        line_num = { enable = false },
        blank = { enable = false },
        chunk = {
          enable = true,
          chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "┌",
            left_bottom = "└",
            right_arrow = "─",
          },
          -- Resolve again after Meian changes light/dark appearance.
          style = function()
            return vim.g.terminal_color_8 or "#808080"
          end,
          duration = 200,
          delay = 500,
          use_treesitter = true,
          exclude_filetypes = { ["copilot-chat"] = true },
        },
      })
    ''
  );
}
