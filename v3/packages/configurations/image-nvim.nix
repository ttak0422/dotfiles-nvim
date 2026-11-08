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
  plugin = sources.image-nvim;
  extraPackages = with pkgs; [
    imagemagick
    ghostscript
  ];
  config = luaConfig (
    # lua
    ''
      -- The package is eager; terminal graphics initialization needs a UI.
      local function setup_image()
        if vim.g.neovide then
          return
        end
        require("image").setup({
          backend = "kitty",
          integrations = {
            markdown = {
              enabled = true,
              clear_in_insert_mode = false,
              download_remote_images = true,
              only_render_image_at_cursor = true,
              only_render_image_at_cursor_mode = "popup",
              floating_windows = false,
              filetypes = { "markdown", "vimwiki" },
            },
          },
          max_height = 20,
          max_height_window_percentage = math.huge,
          max_width_window_percentage = math.huge,
          window_overlap_clear_enabled = true,
          window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
        })
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
}
