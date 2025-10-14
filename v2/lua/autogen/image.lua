-- [nfnl] v2/fnl/image.fnl
if not vim.g.neovide then
  return require("image").setup({backend = "kitty", integrations = {markdown = {enabled = true, download_remote_images = true, only_render_image_at_cursor = true, only_render_image_at_cursor_mode = "popup", filetypes = {"markdown", "vimwiki"}, clear_in_insert_mode = false, floating_windows = false}}, max_width = nil, max_height = 20, max_height_window_percentage = math.huge, max_width_window_percentage = math.huge, window_overlap_clear_enabled = true, window_overlap_clear_ft_ignore = {"cmp_menu", "cmp_docs", ""}})
else
  return nil
end
