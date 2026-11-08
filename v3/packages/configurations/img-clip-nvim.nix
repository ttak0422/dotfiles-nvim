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
  plugin = sources.img-clip-nvim;
  config = luaConfig (
    # lua
    ''
      require("img-clip").setup({
        default = {
          dir_path = ".",
          extension = "png",
          file_name = "%Y-%m-%d_%H%M%S",
          use_absolute_path = false,
          relative_to_current_file = true,
          template = "$FILE_PATH",
          url_encode_path = false,
          relative_template_path = true,
          use_cursor_in_template = true,
          insert_mode_after_paste = true,
          prompt_for_file_name = false,
          show_dir_path_in_prompt = false,
          max_base64_size = 10,
          embed_image_as_base64 = false,
          process_cmd = "",
          copy_images = false,
          download_images = true,
          drag_and_drop = { enabled = true, insert_mode = false },
        },
        filetypes = {
          markdown = {
            url_encode_path = false,
            template = "![$CURSOR]($FILE_PATH)",
            download_images = false,
          },
          html = { template = '<img src="$FILE_PATH" alt="$CURSOR">' },
        },
      })
    ''
  );
}
