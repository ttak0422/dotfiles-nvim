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
  plugin = sources.auto-save-nvim;
  config = luaConfig (
    # lua
    ''
      local targets = { md = true, markdown = true, norg = true, neorg = true }
      require("auto-save").setup({
        events = { "InsertLeave", "TextChanged" },
        debounce_delay = 500,
        condition = function(buf)
          return vim.fn.getbufvar(buf, "&modifiable") == 1
            and targets[vim.fn.getbufvar(buf, "&filetype")] == true
        end,
      })
    ''
  );
}
