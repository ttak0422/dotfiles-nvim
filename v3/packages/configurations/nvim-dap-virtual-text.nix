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
  plugin = sources.nvim-dap-virtual-text;
  dependPlugins = [
    definitions.nvim-dap
    definitions.nvim-treesitter
  ];
  config = luaConfig ''
    require("nvim-dap-virtual-text").setup({
      virt_text_pos = "inline",
      display_callback = function(variable)
        return " = " .. variable.value:gsub("%s+", " ")
      end,
    })
  '';
}
