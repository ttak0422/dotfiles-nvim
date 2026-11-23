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
      local function box()
        return require("win_box")
      end
      local function map(key, callback, description)
        vim.keymap.set("n", "<C-w>" .. key, callback, { silent = true, desc = description })
      end
      for key, direction in pairs({ H = "left", J = "down", K = "up", L = "right" }) do
        map(key, function() box().move(direction) end, "Move window " .. direction)
      end
      map("<C-w>", function() box().swap() end, "Swap windows")
      map("p", function() box().pick() end, "Pick window")
      map("e", function() box().adjust() end, "Adjust window")
    ''
  );
}
