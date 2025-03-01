(local M (require :toggler))

(fn with_keep_window [f]
  (fn []
    (let [win (vim.api.nvim_get_current_win)]
      (f)
      (vim.api.nvim_set_current_win win))))

; quickfix
(M.register :qf {:open (with_keep_window (fn [] (vim.cmd :copen)))
                 :close (fn [] (vim.cmd :cclose))
                 :is_open (fn []
                            (not= (-> (vim.fn.getqflist {:winid 0})
                                      (. :winid))
                                  0))})

; toggleterm
(let [st {}
      open_idx (fn [idx]
                 (-> (case (. st idx)
                       term term
                       _ (let [term (-> (require :toggleterm.terminal)
                                        (. :Terminal)
                                        (: :new {:direction :float}))]
                           (tset st idx term)
                           term))
                     (: :open)))
      is_open_idx (fn [idx]
                    (let [term (. st idx)]
                      (and term (term:is_open))))
      close_idx (fn [idx]
                  (let [term (. st idx)]
                    (if (and term (term:is_open))
                        (term:close))))]
  (for [i 0 9]
    (M.register (.. :term i)
                {:open (fn [] (open_idx i))
                 :close (fn [] (close_idx i))
                 :is_open (fn [] (is_open_idx i))})
    (vim.api.nvim_create_user_command (.. :ClearTerm i) (fn [] (tset st i nil))
                                      {})))

; trouble
(let [st {:recent_type nil}
      mk_open (fn [opt type]
                (with_keep_window (fn []
                                    ((. (require :trouble) :open) opt)
                                    (tset st :recent_type type))))
      close (fn []
              (case (. package.loaded :trouble)
                t (t.close)))
      mk_is_open (fn [type]
                   (fn []
                     (case (. package.loaded :trouble)
                       t (and (t.is_open) (= st.recent_type type))
                       _ false)))]
  (M.register :trouble-doc
              {:open (mk_open {:mode :diagnostics :filter {:buf 0}} :doc)
               : close
               :is_open (mk_is_open :doc)})
  (M.register :trouble-ws {:open (mk_open {:mode :diagnostics} :ws)
                           : close
                           :is_open (mk_is_open :ws)}))
