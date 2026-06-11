-- [nfnl] v2/fnl/worktab.fnl
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
