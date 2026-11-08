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
  plugin = image-nvim;
  extraPackages = with pkgs; [
    imagemagick
    ghostscript
  ];
  config = luaConfig (
    # lua
    ''
      -- The package is eager; terminal graphics initialization needs a UI.
      local function setup_image()
        if vim.g.neovide then return end
        return require("image").setup({backend = "kitty", integrations = {markdown = {enabled = true, download_remote_images = true, only_render_image_at_cursor = true, only_render_image_at_cursor_mode = "popup", filetypes = {"markdown", "vimwiki"}, clear_in_insert_mode = false, floating_windows = false}}, max_width = nil, max_height = 20, max_height_window_percentage = math.huge, max_width_window_percentage = math.huge, window_overlap_clear_enabled = true, window_overlap_clear_ft_ignore = {"cmp_menu", "cmp_docs", ""}})
      end
      if not vim.g.neovide then
        if #vim.api.nvim_list_uis() > 0 then
          setup_image()
        else
          vim.api.nvim_create_autocmd("UIEnter", { once = true, callback = setup_image })
        end
      end
    ''
  );
  doc = "Enabled v2/default image configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
