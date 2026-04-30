(local augroup (vim.api.nvim_create_augroup :ttak-gitu {:clear false}))
(local gitu-pattern "term://.*:gitu$")

(fn gitu-buffer? [buf]
  (and (vim.api.nvim_buf_is_valid buf)
       (or (= true (. vim.b buf :gitu))
           (let [name (vim.api.nvim_buf_get_name buf)]
             (and (name:match gitu-pattern) true)))))

(fn gitu-running-buffer? [buf]
  (and (gitu-buffer? buf) (= true (. vim.b buf :gitu_running))))

(fn normal-win-count []
  (var count 0)
  (each [_ win (ipairs (vim.api.nvim_list_wins))]
    (when (= "" (. (vim.api.nvim_win_get_config win) :relative))
      (set count (+ count 1))))
  count)

(fn split-for-gitu []
  (let [width vim.o.columns
        height vim.o.lines]
    (if (> (/ width height) 2.5)
        (vim.cmd :vsplit)
        (vim.cmd :split))))

(fn startinsert-if-current [buf]
  (vim.schedule #(when (and (vim.api.nvim_buf_is_valid buf)
                            (= (vim.api.nvim_get_current_buf) buf))
                   (vim.cmd :startinsert))))

(fn with-editor-origin [win buf f]
  (let [prev-editor-win vim.env.NVIM_EDITOR_WIN
        prev-editor-buf vim.env.NVIM_EDITOR_BUF]
    (set vim.env.NVIM_EDITOR_WIN (tostring win))
    (set vim.env.NVIM_EDITOR_BUF (tostring buf))
    (let [(ok? result) (pcall f)]
      (set vim.env.NVIM_EDITOR_WIN prev-editor-win)
      (set vim.env.NVIM_EDITOR_BUF prev-editor-buf)
      (if ok?
          result
          (error result)))))

(fn focus-gitu-buffer [buf]
  (let [wins (vim.fn.win_findbuf buf)]
    (if (> (length wins) 0)
        (vim.api.nvim_set_current_win (. wins 1))
        (do
          (when (= (normal-win-count) 1)
            (split-for-gitu))
          (vim.api.nvim_win_set_buf 0 buf))))
  (startinsert-if-current buf))

(fn delete-gitu-buffer [buf]
  (pcall #((. (require :snacks) :bufdelete) {: buf :force true})))

(fn close-gitu-buffer [buf win did-split]
  (when (vim.api.nvim_buf_is_valid buf)
    (if (and did-split (vim.api.nvim_win_is_valid win))
        (let [ok? (pcall vim.api.nvim_win_close win true)]
          (when (not ok?)
            (delete-gitu-buffer buf)))
        (delete-gitu-buffer buf))))

(fn gitu []
  (let [running-buf (-> (vim.api.nvim_list_bufs)
                        (vim.iter)
                        (: :find gitu-running-buffer?))]
    (if running-buf
        (focus-gitu-buffer running-buf)
        (let [did-split (= (normal-win-count) 1)]
          (when did-split
            (split-for-gitu))
          (vim.cmd :enew)
          (let [buf (vim.api.nvim_get_current_buf)
                win (vim.api.nvim_get_current_win)]
            (vim.api.nvim_buf_set_var buf :gitu true)
            (vim.api.nvim_buf_set_var buf :gitu_running true)
            (vim.api.nvim_set_option_value :buflisted false {: buf})
            (vim.api.nvim_set_option_value :bufhidden :wipe {: buf})
            (vim.api.nvim_create_autocmd :BufEnter
                                         {:group augroup
                                          :buffer buf
                                          :callback #(startinsert-if-current buf)})
            (let [job (with-editor-origin win
                        buf
                        #(vim.fn.jobstart [:gitu]
                                          {:term true
                                           :on_exit (fn [_ status _]
                                                      (when (vim.api.nvim_buf_is_valid buf)
                                                        (vim.api.nvim_buf_set_var buf
                                                                                  :gitu_running
                                                                                  false))
                                                      (if (= status 0)
                                                          (vim.schedule #(close-gitu-buffer buf
                                                                                            win
                                                                                            did-split))
                                                          (vim.schedule #(vim.notify (.. "gitu exited with code "
                                                                                         status)
                                                                                     vim.log.levels.WARN))))}))]
              (if (<= job 0)
                  (do
                    (vim.notify "failed to start gitu" vim.log.levels.ERROR)
                    (delete-gitu-buffer buf))
                  (vim.cmd :startinsert))))))))

(vim.api.nvim_create_user_command :Gitu gitu {})

(vim.api.nvim_create_user_command :GituClear
                                  #(each [_ buf (ipairs (vim.api.nvim_list_bufs))]
                                     (when (gitu-buffer? buf)
                                       (delete-gitu-buffer buf)))
                                  {})
