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
  plugin = sources.worktab-nvim;
  config = luaConfig (
    # lua
    ''
      local worktab = require("worktab")
      vim.api.nvim_create_user_command("Tabnew", function(opts)
        vim.cmd.tabnew()
        if opts.args ~= "" then
          worktab.set_name(opts.args)
        end
      end, { nargs = "?", desc = "Open a new tab with an optional name" })
    ''
  );
}
