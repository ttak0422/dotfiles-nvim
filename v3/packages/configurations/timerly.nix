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
  plugin = sources.timerly;
  dependPlugins = [
    definitions.volt
  ];
  config = luaConfig (
    # lua
    ''
      require("timerly").setup({
        position = "top-right",
        mapping = function(buf)
          vim.keymap.set("n", "<CR>", require("timerly.api").togglestatus, { buffer = buf })
        end,
      })
    ''
  );
}
