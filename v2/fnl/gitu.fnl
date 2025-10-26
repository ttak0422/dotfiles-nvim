(local Snacks (require :snacks))
(var terminal nil)

(fn win_valid? [win]
  (and win (vim.api.nvim_win_is_valid win)))

(fn buf_valid? [buf]
  (and buf (vim.api.nvim_buf_is_valid buf)))

(fn buf_term? [buf]
  (and buf (= (vim.api.nvim_buf_get_option buf :buftype) :terminal)))

(local cmd :gitu)
(local opts {:win {:position :left :width 0.4}})

(fn close []
  (when (and terminal (terminal:buf_valid))
    (vim.api.nvim_win_close terminal.win false)))

(fn open []
  (if (and terminal (terminal:buf_valid))
      ;; terminal exists
      (do
        (when (not (win_valid? terminal.win)) (terminal:toggle))
        (terminal:focus)
        (when (and (win_valid? terminal.win) (buf_term? terminal.buf))
          (vim.api.nvim_win_call terminal.win #(vim.cmd.startinsert))))
      ;; terminal not exists
      (let [term_instance (Snacks.terminal.open cmd opts)]
        (if (and term_instance (term_instance:buf_valid))
            (do
              (doto term_instance
                ; (: :on :TermClose
                ;    (fn []
                ;      (set terminal nil)
                ;      (vim.schedule #(if term_instance
                ;                         (do
                ;                           (term_instance:close {:buf true})
                ;                           (vim.cmd.checktime)))))
                ;    {:buf true})
                ; (: :on :BufWipeout #(set terminal nil) {:buf true})
                (: :on :BufLeave #(vim.defer_fn close 10) {:buf true}))
              (set terminal term_instance))
            (do
              (vim.notify "Failed to open gitu" vim.log.levels.ERROR)
              (set terminal nil))))))

(fn toggle []
  (if (and terminal (terminal:buf_valid))
      ;; terminal exists
      (if (terminal:win_valid)
          ;; visible
          (do
            (vim.notfiy "terminal visible")
            (let [current_win_id (vim.api.nvim_get_current_win)
                  target_win_id terminal.win]
              (if (= target_win_id current_win_id)
                  ;; currently focused
                  (terminal:toggle)
                  ;; currently not focused
                  (do
                    (vim.api.nvim_set_current_win target_win_id)
                    (if (and (buf_valid? terminal.buf) (buf_term? terminal.buf))
                        (vim.cmd.startinsert))))))
          ;; not visible
          (terminal:toggle))
      ;; terminal not exists
      (open)))

(vim.api.nvim_create_user_command :Gitu toggle {})
