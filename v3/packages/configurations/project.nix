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
  plugin = project-nvim;
  config = luaConfig (
    # lua
    ''
      local project = require("project_nvim")
      project.setup({scope_chdir = "tab", detection_methods = {"pattern"}, patterns = {".git"}, manual_mode = false})
      local augroup = vim.api.nvim_create_augroup("ProjectSubmoduleGuard", {clear = true})
      local adjusting = false
      local function superproject_root(dir)
        local out = vim.fn.system({"git", "-C", dir, "rev-parse", "--show-superproject-working-tree"})
        local root = vim.trim(out)
        if ((vim.v.shell_error == 0) and (root ~= "")) then
          return root
        else
          return nil
        end
      end
      local function _2_()
        if not adjusting then
          local root = superproject_root(vim.fn.getcwd())
          if root then
            adjusting = true
            pcall(vim.cmd.tcd, vim.fn.fnameescape(root))
            adjusting = false
            return nil
          else
            return nil
          end
        else
          return nil
        end
      end
      return vim.api.nvim_create_autocmd("DirChanged", {group = augroup, pattern = {"global", "tabpage"}, callback = _2_})
    ''
  );
  doc = "Enabled v2/default project configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
