{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  emptyPlugin,
  inputs',
}:
with sources;
with definitions;
{
  plugin = worktab-nvim;
  config = luaConfig (
    # lua
    ''
      local worktab = require("worktab")
      local function _1_(opts)
        vim.cmd.tabnew()
        if (opts.args ~= "") then
          return worktab.set_name(opts.args)
        else
          return nil
        end
      end
      return vim.api.nvim_create_user_command("Tabnew", _1_, {nargs = "?", desc = "Open a new tab with an optional name"})
    ''
  );
  doc = "Enabled v2/default worktab configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
