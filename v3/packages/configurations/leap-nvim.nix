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
  plugin = sources.leap-nvim;
  dependPlugins = [
    definitions.vim-repeat
  ];
  config = luaConfig (
    # lua
    ''
      local leap = require("leap")
      local traversal_keys = require("leap.user").with_traversal_keys
      local clever_f = traversal_keys("f", "F")
      local clever_t = traversal_keys("t", "T")

      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)", {
        noremap = true, silent = true, desc = "Leap",
      })
      vim.keymap.set("n", "S", "<Plug>(leap-from-window)", {
        noremap = true, silent = true, desc = "Leap from window",
      })

      for key, spec in pairs({
        f = { opts = clever_f },
        F = { backward = true, opts = clever_f },
        t = { offset = -1, opts = clever_t },
        T = { backward = true, offset = 1, opts = clever_t },
      }) do
        vim.keymap.set({ "n", "x", "o" }, key, function()
          leap.leap(vim.tbl_deep_extend("keep", spec, {
            inputlen = 1,
            inclusive = true,
            opts = {
              labels = "",
              safe_labels = vim.fn.mode(1):match("o") and "" or nil,
            },
          }))
        end)
      end
    ''
  );
}
