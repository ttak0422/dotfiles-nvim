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
  plugin = sources.replua-nvim;
  config = luaConfig (
    # lua
    ''
      require("replua").setup({
        keymaps = {
          eval_line = "<LocalLeader>rl",
          eval_block = "<LocalLeader>rr",
          eval_buffer = "<LocalLeader>rA",
        },
      })
    ''
  );
}
