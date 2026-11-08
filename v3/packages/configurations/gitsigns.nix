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
  plugin = gitsigns-nvim;
  dependPlugins = [ plenary ];
  config = luaConfig (
    # lua
    ''
      local signs = require("gitsigns")
      local current_line_blame_opts = {virt_text = true, virt_text_pos = "eol", delay = 1000, virt_text_priority = 300, use_focus = true, ignore_whitespace = false}
      return signs.setup({signcolumn = true, numhl = true, current_line_blame_formatter = "<author> <author_time:%Y-%m-%d> - <summary>", sign_priority = 6, update_debounce = 1000, max_file_length = 40000, current_line_blame = true, current_line_blame_opts = current_line_blame_opts, linehl = false, word_diff = false})
    ''
  );
  doc = "Enabled v2/default gitsigns configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
