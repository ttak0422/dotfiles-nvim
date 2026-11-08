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
  plugin = sources.rustowl.overrideAttrs {
    # WIP: use `cargo binstall rustowl`
    # runtimeDeps = with pkgs.v2; [ rustowl ];
  };
  config = luaConfig (
    # lua
    ''
      local rustowl = require("rustowl")
      rustowl.setup({
        auto_attach = true,
        auto_enable = false,
        idle_time = 1000,
        highlight_style = "underline",
        client = {
          on_attach = function(_, buffer)
            vim.keymap.set("n", "<LocalLeader>to", function()
              rustowl.toggle(buffer)
            end, { buffer = buffer, desc = "Toggle RustOwl" })
          end,
        },
      })
    ''
  );
}
