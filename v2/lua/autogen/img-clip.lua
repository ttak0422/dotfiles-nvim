-- [nfnl] v2/fnl/img-clip.fnl
local clip = require("img-clip")
local default = {dir_path = ".", extension = "png", file_name = "%Y-%m-%d_%H%M%S", relative_to_current_file = true, template = "$FILE_PATH", relative_template_path = true, use_cursor_in_template = true, insert_mode_after_paste = true, max_base64_size = 10, process_cmd = "", download_images = true, drag_and_drop = {enabled = true, insert_mode = false}, copy_images = false, embed_image_as_base64 = false, prompt_for_file_name = false, show_dir_path_in_prompt = false, url_encode_path = false, use_absolute_path = false}
local filetypes = {markdown = {template = "![$CURSOR]($FILE_PATH)", download_images = false, url_encode_path = false}, html = {template = "<img src=\"$FILE_PATH\" alt=\"$CURSOR\">"}}
return clip.setup({default = default, filetypes = filetypes})
