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
  plugin = sources.other-nvim;
  config = luaConfig (
    # lua
    ''
      local transformers = require("other-nvim.builtin.transformers")
      require("other-nvim").setup({
        showMissingFiles = true,
        rememberBuffers = false,
        mappings = { "c", "clojure", "elixir", "golang", "python", "react", "rust" },
        transformers = {
          camelToKebap = transformers.camelToKebap,
          kebapToCamel = transformers.kebapToCamel,
          pluralize = transformers.pluralize,
          singularize = transformers.singularize,
        },
        keybindings = {
          ["<cr>"] = "open_file_by_command()",
          ["<esc>"] = "close_window()",
          ["<C-w>o"] = "open_file()",
          ["<C-w>t"] = "open_file_tabnew()",
          ["<C-w>q"] = "close_window()",
          ["<C-w>v"] = "open_file_vs()",
          ["<C-w>s"] = "open_file_sp()",
        },
      })
    ''
  );
}
