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
  plugin = sources.nvim-ufo;
  dependPlugins = [
    definitions.promise-async
  ];
  config = luaConfig (
    # lua
    ''
      local ufo = require("ufo")
      ufo.setup({
        provider_selector = function()
          return { "treesitter", "indent" }
        end,
      })
      for _, mapping in ipairs({
        { "zR", ufo.openAllFolds, " open all folds" },
        { "zr", ufo.openFoldsExceptKinds, " open folds" },
        { "zM", ufo.closeAllFolds, " close all folds" },
        { "zm", ufo.closeAllFolds, " close all folds" },
      }) do
        vim.keymap.set("n", mapping[1], mapping[2], {
          noremap = true,
          silent = true,
          desc = mapping[3],
        })
      end
    ''
  );
}
