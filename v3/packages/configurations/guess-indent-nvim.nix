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
  plugin = sources.guess-indent-nvim;
  config = luaConfig (
    # lua
    ''
      require("guess-indent").setup({
        auto_cmd = true,
        filetype_exclude = { "netrw", "tutor" },
        buftype_exclude = { "help", "nofile", "terminal", "prompt" },
        on_tab_options = { expandtab = false },
        on_space_options = {
          expandtab = true,
          tabstop = "detected",
          softtabstop = "detected",
          shiftwidth = "detected",
        },
        override_editorconfig = false,
      })
    ''
  );
}
