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
  plugin = sources.smart-splits-nvim;
  config = luaConfig (
    # lua
    ''
      require("smart-splits").setup({
        ignored_filetypes = { "nofile", "quickfix", "prompt" },
        ignored_buftypes = { "NvimTree" },
        ignored_events = { "BufEnter", "WinEnter" },
      })
    ''
  );
}
