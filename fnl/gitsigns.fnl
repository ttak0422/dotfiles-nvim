(let [M (require :gitsigns)
      current_line_blame_opts {:virt_text true
                               :virt_text_pos :eol
                               :delay 1000
                               :ignore_whitespace false}
      preview_config {:border :none
                      :style :minimal
                      :relative :cursor
                      :row 0
                      :col 1}]
  (M.setup {:signcolumn true
            :numhl true
            :current_line_blame true
            :current_line_blame_formatter "<author> <author_time:%Y-%m-%d> - <summary>"
            :sign_priority 6
            :update_debounce 1000
            :max_file_length 40000
            : current_line_blame_opts
            : preview_config}))

(vim.api.nvim_create_user_command :ToggleGitBlame
                                  (fn []
                                    (let [wins []]
                                      (each [_ win (ipairs (vim.api.nvim_list_wins))]
                                        (let [buf (vim.api.nvim_win_get_buf win)
                                              filetype (vim.api.nvim_buf_get_option buf
                                                                                    :filetype)]
                                          (if (= filetype :gitsigns-blame)
                                              (tset wins (+ (length wins) 1)
                                                    win))))
                                      (if (not= (length wins) 0)
                                          (each [_ win (ipairs wins)]
                                            (vim.api.nvim_win_close win true))
                                          (vim.cmd "Gitsigns blame"))))
                                  {})
