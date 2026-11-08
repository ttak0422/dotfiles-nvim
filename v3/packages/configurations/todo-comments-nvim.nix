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
  plugin = sources.todo-comments-nvim;
  dependPlugins = [
    definitions.nvim-web-devicons
    definitions.trouble-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("todo-comments").setup({
        signs = true,
        keywords = {
          FIX = { icon = "", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
          TODO = { icon = "", color = "info" },
          HACK = { icon = "", color = "warning" },
          WARN = { icon = "", color = "warning", alt = { "WARNING", "XXX" } },
          PERF = { icon = "", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
          NOTE = { icon = "", color = "hint", alt = { "INFO" } },
          TEST = { icon = "", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
        },
      })
    ''
  );
  extraPackages = with pkgs; [ ripgrep ];
}
