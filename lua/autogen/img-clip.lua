-- [nfnl] Compiled from fnl/img-clip.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("img-clip")
local filetypes = {markdown = {template = "![$CURSOR]($FILE_PATH)", download_images = true, url_encode_path = false}}
local default = {drag_and_drop = {insert_mode = true}, embed_image_as_base64 = false, prompt_for_file_name = false}
return M.setup({default = default, filetypes = filetypes})
