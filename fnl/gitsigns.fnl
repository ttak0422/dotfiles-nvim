(local signs (require :gitsigns))
(let [current_line_blame_opts {:virt_text true
                               :virt_text_pos :eol
                               :virt_text_priority 300
                               :delay 1000
                               :ignore_whitespace false}
      preview_config {:border :none
                      :style :minimal
                      :relative :cursor
                      :row 0
                      :col 1}]
  (signs.setup {:signcolumn true
                :numhl true
                :current_line_blame true
                :current_line_blame_formatter "<author> <author_time:%Y-%m-%d> - <summary>"
                :sign_priority 6
                :update_debounce 1000
                :max_file_length 40000
                : current_line_blame_opts
                : preview_config}))
