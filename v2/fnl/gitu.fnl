(local Snacks (require :snacks))
(var terminal nil)

(fn win_valid? [win]
  (and win (vim.api.nvim_win_is_valid win)))

(fn buf_valid? [buf]
  (and buf (vim.api.nvim_buf_is_valid buf)))

(fn buf_term? [buf]
  (and buf (= (vim.api.nvim_buf_get_option buf :buftype) :terminal)))

(local cmd :gitu)
(local opts {:win {:position :float :width 0.75 :fixbuf false}})

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
                (: :on :TermClose
                   (fn []
                     ;; only clear if this instance is still the current terminal
                     (when (= terminal term_instance)
                       (set terminal nil))) {:buf true})
                (: :on :BufLeave
                   (fn []
                     (vim.schedule (fn []
                                     (when (and (= terminal term_instance)
                                                (term_instance:win_valid)
                                                (not (= (vim.api.nvim_get_current_buf)
                                                        term_instance.buf)))
                                       (term_instance:hide)))))
                   {:buf true})
                (: :on :BufWipeout
                   (fn []
                     (when (= terminal term_instance)
                       (set terminal nil))) {:buf true}))
              (set terminal term_instance))
            (do
              (vim.notify "Failed to open gitu" vim.log.levels.ERROR)
              (set terminal nil))))))

(fn toggle []
  (if (and terminal (terminal:buf_valid))
      ;; terminal exists
      (if (terminal:win_valid)
          ;; visible
          (let [current_win_id (vim.api.nvim_get_current_win)
                target_win_id terminal.win]
            (if (= target_win_id current_win_id)
                ;; currently focused
                (terminal:toggle)
                ;; currently not focused
                (do
                  (vim.api.nvim_set_current_win target_win_id)
                  (when (and (buf_valid? terminal.buf) (buf_term? terminal.buf))
                    (vim.cmd.startinsert)))))
          ;; not visible
          (terminal:toggle))
      ;; terminal not exists (clear stale reference if any)
      (do
        (set terminal nil)
        (open))))

(vim.api.nvim_create_user_command :Gitu toggle {})
