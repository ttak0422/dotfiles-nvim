(let [M (require :img-clip)
      filetypes {:markdown {:url_encode_path false
                            :template "![$CURSOR]($FILE_PATH)"
                            :download_images true}}
      default {:embed_image_as_base64 false
               :prompt_for_file_name false
               :drag_and_drop {:insert_mode true}}]
  (M.setup {: default : filetypes}))
