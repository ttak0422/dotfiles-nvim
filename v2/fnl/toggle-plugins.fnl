(local toggler (require :toggler))

(fn with_keep_window [f]
  (fn []
    (let [win (vim.api.nvim_get_current_win)]
      (f)
      (vim.api.nvim_set_current_win win))))

;;; quickfix ;;;
(toggler.register :qf {:open (with_keep_window (fn [] (vim.cmd :copen)))
                       :close (fn [] (vim.cmd :cclose))
                       :is_open (fn []
                                  (not= (-> (vim.fn.getqflist {:winid 0})
                                            (. :winid))
                                        0))})

;;; terminal ;;;
; NOTE: `toggleterm-nvim` and `tmux` required
(fn tmux_attach_or_create [session window]
  (if (-> (vim.system [:tmux :has-session :-t session])
          (: :wait)
          (. :code)
          (not= 0))
      (: (vim.system [:tmux :new-session :-d :-s session]) :wait))
  (if (not= window "")
      (let [windows (-> (vim.system [:tmux :list-windows :-t session])
                        (: :wait)
                        (. :stdout)
                        (: :gmatch "[^\n]+"))
            exists (accumulate [acc false w _ windows]
                     (or acc
                         (not= (w:match (.. "^" (vim.pesc window) ":")) nil)))]
        (if (not exists)
            (: (vim.system [:tmux :new-window :-t (.. session ":" window)])
               :wait)))))

(local toggleterm {})
(let [open_idx (fn [idx]
                 (let [terminal (require :toggleterm.terminal)
                       cwd (vim.fn.fnamemodify (vim.fn.getcwd) ":t")
                       target (.. cwd "_" idx)]
                   (tmux_attach_or_create target :0)
                   (-> (or (. toggleterm idx)
                           (let [t (terminal.Terminal:new {:direction :float
                                                           :float_opts {:border :single}
                                                           :cmd (.. "tmux attach-session -t "
                                                                    target)})]
                             (tset toggleterm idx t)
                             t))
                       (: :open))))
      is_open_idx (fn [idx]
                    (let [t (. toggleterm idx)] (and t (t:is_open))))
      close_idx (fn [idx]
                  (let [t (. toggleterm idx)]
                    (if (and t (t:is_open))
                        (t:close))))]
  (for [i 0 9]
    (toggler.register (.. :term i)
                      {:open (fn [] (open_idx i))
                       :close (fn [] (close_idx i))
                       :is_open (fn [] (is_open_idx i))})))
