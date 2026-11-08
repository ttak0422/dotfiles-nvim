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
  plugin = sources.inc-rename-nvim;
  config = luaConfig (
    # lua
    ''
      require("inc_rename").setup({
        preview_empty_name = false,
        save_in_cmdline_history = false,
        show_message = false,
      })
    ''
  );
}
