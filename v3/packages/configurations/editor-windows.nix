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
  config = luaConfig (
    # lua
    ''
      for key, direction in pairs({
        H = "left",
        J = "down",
        K = "up",
        L = "right",
        ["<C-w>"] = "swap",
      }) do
        vim.keymap.set("n", "<C-w>" .. key, "<Cmd>WinShift " .. direction .. "<CR>", {
          noremap = true,
          silent = true,
        })
      end
      vim.keymap.set("n", "<C-w>p", function()
        require("nvim-window").pick()
      end, { noremap = true, silent = true, desc = "pick window" })
    ''
  );
}
