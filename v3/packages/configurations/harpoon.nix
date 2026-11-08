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
  plugin = sources.harpoon;
  dependPlugins = [
    definitions.plenary-nvim
  ];
  config = luaConfig (
    # lua
    ''
      local function display(item)
        local value = item.value or ""
        local repo = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
        local filename = vim.fn.fnamemodify(value, ":t")
        local dir = vim.fn.fnamemodify(value, ":h")
        if dir == "." or dir == "" then
          return string.format("%s  %s", filename, repo)
        end
        return string.format("%s  %s/%s", filename, repo, dir)
      end
      require("harpoon").setup({
        settings = { key = vim.uv.cwd, save_on_toggle = false, sync_on_ui_close = false },
        default = { display = display },
      })
    ''
  );
}
