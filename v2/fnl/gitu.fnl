(fn gitu []
  (let [wins (vim.api.nvim_list_wins)
        win-count (length wins)
        did-split (= win-count 1)]
    (when did-split
      (let [width vim.o.columns
            height vim.o.lines]
        (if (> (/ width height) 2.5)
            (vim.cmd :vsplit)
            (vim.cmd :split))))
    (vim.cmd "terminal gitu")
    (let [buf (vim.api.nvim_get_current_buf)
          win (vim.api.nvim_get_current_win)]
      (vim.api.nvim_create_autocmd :TermClose
                                   {:buffer buf
                                    :callback (fn []
                                                (vim.schedule (fn []
                                                                (when (vim.api.nvim_buf_is_valid buf)
                                                                  (if did-split
                                                                      (when (vim.api.nvim_win_is_valid win)
                                                                        (vim.api.nvim_win_close win
                                                                                                true))
                                                                      ((. (require :snacks)
                                                                          :bufdelete) {: buf
                                                                                       :force true}))))))}))
    (vim.cmd :startinsert)))

(vim.api.nvim_create_user_command :Gitu gitu {})

(vim.api.nvim_create_user_command :GituClear
                                  (fn []
                                    (each [_ buf (ipairs (vim.api.nvim_list_bufs))]
                                      (let [name (vim.api.nvim_buf_get_name buf)]
                                        (when (name:match "term://.*gitu$")
                                          ((. (require :snacks) :bufdelete) {: buf
                                                                             :force true})))))
                                  {})
