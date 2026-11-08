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
  plugin = emptyPlugin "lspPlugins";
  dependPlugins = [
    {
      plugin = Ionide-vim;
      preConfig = luaConfig (
        # lua
        ''
          vim.g["fsharp#lsp_recommended_colorscheme"] = 0
          vim.g["fsharp#lsp_codelens"] = 0
          return nil
        ''
      );
      config = luaConfig (
        # lua
        ''
          vim.lsp.config("ionide", {})
          return vim.lsp.enable("ionide")
        ''
      );
      extraPackages = with pkgs; [
        dotnet-sdk_9
        fsautocomplete
      ];
    }
    {
      plugin = lensline-nvim;
      config = luaConfig (
        # lua
        ''
          local ll = require("lensline")
          return ll.setup({debounce_ms = 1000, focused_debounce_ms = 200, profiles = {{name = "default", style = {placement = "inline", prefix = "", render = "focused"}}}})
        ''
      );
    }
    {
      plugin = garbage-day-nvim;
      config = luaConfig (
        # lua
        ''
          local gc = require("garbage-day")
          return gc.setup({excluded_lsp_clients = {"jdtls"}, grace_period = (60 * 30), wakeup_delay = 500})
        ''
      );
    }
    {
      plugin = tiny-inline-diagnostic-nvim;
      config = luaConfig (
        # lua
        ''
          local diag = require("tiny-inline-diagnostic")
          return diag.setup({preset = "classic", transparent_bg = true, hi = {error = "GitSignsDelete", warn = "GitSignsAdd", info = "GitSignsChange", arrow = "NonText", background = "CursorLine", mixing_color = "None"}, virt_texts = {priority = 2048}, options = {severity = {vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN, vim.diagnostic.severity.INFO}}})
        ''
      );
    }
    {
      plugin = neogen;
      dependPlugins = [ luasnip ];
      config = luaConfig (
        # lua
        ''
          local neogen = require("neogen")
          return neogen.setup({snippet_engine = "luasnip"})
        ''
      );
    }
  ];
  doc = "Enabled v2/default lspPlugins configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
