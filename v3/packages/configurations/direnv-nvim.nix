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
  plugin = sources.direnv-nvim;
  config = luaConfig (
    # lua
    ''
      if vim.g.direnv_nvim_original_path == nil then
        vim.g.direnv_nvim_original_path = vim.env.PATH or ""
      end
      local function split_path(path)
        return vim.split(path or "", ":", { plain = true, trimempty = true })
      end
      local function merge_path(current, original)
        local items = split_path(current)
        local seen = {}
        for _, item in ipairs(items) do
          seen[item] = true
        end
        for _, item in ipairs(split_path(original)) do
          if not seen[item] then
            table.insert(items, item)
            seen[item] = true
          end
        end
        return table.concat(items, ":")
      end
      vim.api.nvim_create_autocmd("User", {
        pattern = "DirenvLoaded",
        callback = function()
          vim.env.PATH = merge_path(vim.env.PATH, vim.g.direnv_nvim_original_path)
        end,
      })
      require("direnv").setup({
        autoload_direnv = true,
        statusline = { enabled = false },
        keybindings = {},
        notifications = { silent_autoload = true },
      })
    ''
  );
  extraPackages = with pkgs; [ direnv ];
}
