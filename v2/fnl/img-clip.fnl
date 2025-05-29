(local clip (require :img-clip))
(local default
       {:dir_path :assets
        :extension :png
        :file_name "%Y%m%d%H%M%S"
        :use_absolute_path false
        :relative_to_current_file false
        ;; template options
        :template :$FILE_PATH
        :url_encode_path false
        :relative_template_path true
        :use_cursor_in_template true
        :insert_mode_after_paste true
        :prompt_for_file_name true
        :show_dir_path_in_prompt false
        ;; base64 options
        :max_base64_size 10
        :embed_image_as_base64 false
        ;; image options
        :process_cmd ""
        :copy_images false
        :download_images true
        ;; drag and drop options
        :drag_and_drop {:enabled true :insert_mode false}})

(local filetypes
       {:markdown {:url_encode_path false
                   :template "![$CURSOR]($FILE_PATH)"
                   :download_images false}
        :html {:template "<img src=\"$FILE_PATH\" alt=\"$CURSOR\">"}})

(clip.setup {: default : filetypes})
