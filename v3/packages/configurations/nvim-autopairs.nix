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
  plugin = sources.nvim-autopairs;
  config = luaConfig (
    # lua
    ''
      local autopairs = require("nvim-autopairs")
      local rule = require("nvim-autopairs.rule")
      autopairs.setup({
        map_cr = true,
        check_ts = true,
        ts_config = { go = false },
        disable_filetype = { "TelescopePrompt", "spectre_panel", "norg" },
      })
      autopairs.add_rules({ rule('"""', '"""', "java") })
    ''
  );
}
