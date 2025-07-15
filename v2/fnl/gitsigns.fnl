(local signs (require :gitsigns))

(local current_line_blame_opts {:virt_text true
                                :virt_text_pos :eol
                                :delay 1000
                                :ignore_whitespace false
                                :virt_text_priority 300
                                :use_focus true})

(signs.setup {:signcolumn true
              :numhl true
              :linehl false
              :word_diff false
              :current_line_blame_formatter "<author> <author_time:%Y-%m-%d> - <summary>"
              :sign_priority 6
              :update_debounce 1000
              :max_file_length 40000
              :current_line_blame true
              : current_line_blame_opts})
