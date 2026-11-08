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
  plugin = sources.tiny-glimmer-nvim;
  config = luaConfig (
    # lua
    ''
      require("tiny-glimmer").setup({
        enabled = true,
        overwrite = {
          search = { enabled = false },
          paste = { enabled = true },
          yank = { enabled = true },
          undo = { enabled = true },
          redo = { enabled = true },
        },
      })
    ''
  );
}
