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
  plugin = sources.project-nvim;
  config = luaConfig (
    # lua
    ''
      require("project_nvim").setup({
        scope_chdir = "tab",
        detection_methods = { "pattern" },
        patterns = { ".git" },
        manual_mode = false,
      })
      local group = vim.api.nvim_create_augroup("ProjectSubmoduleGuard", { clear = true })
      local adjusting = false
      local function superproject_root(dir)
        local output = vim.fn.system({ "git", "-C", dir, "rev-parse", "--show-superproject-working-tree" })
        local root = vim.trim(output)
        if vim.v.shell_error == 0 and root ~= "" then
          return root
        end
      end
      -- Keep project.nvim from moving into a submodule instead of its superproject.
      vim.api.nvim_create_autocmd("DirChanged", {
        group = group,
        pattern = { "global", "tabpage" },
        callback = function()
          if adjusting then
            return
          end
          local root = superproject_root(vim.fn.getcwd())
          if root then
            adjusting = true
            pcall(vim.cmd.tcd, vim.fn.fnameescape(root))
            adjusting = false
          end
        end,
      })
    ''
  );
}
