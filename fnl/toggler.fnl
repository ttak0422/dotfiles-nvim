(local M (require :toggler))

(local map vim.keymap.set)
(local create_command vim.api.nvim_create_user_command)

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
    (create_command (.. :ClearTerm i) (fn [] (tset st i nil)) {})))

; gitu
(let [st {:term nil}
      is_open (fn []
                (let [term (. st :term)]
                  (and term (term:is_open))))
      close (fn []
              (let [term (. st :term)]
                (if (and term (term:is_open))
                    (term:close))))
      on_create (fn [term]
                  (map :t :<ESC> :i<ESC>
                       {:buffer term.bufnr :noremap true :silent true})
                  (vim.api.nvim_create_autocmd :BufLeave
                                               {:buffer term.bufnr
                                                :callback close}))
      open (fn []
             (-> (case (. st :term)
                   term term
                   _ (let [term (-> (require :toggleterm.terminal)
                                    (. :Terminal)
                                    (: :new
                                       {:cmd :gitu :hidden true : on_create}))]
                       (tset st :term term)
                       term))
                 (: :open))
             (vim.cmd :startinsert))]
  (M.register :gitu {: open : close : is_open})
  (create_command :ClearGitu (fn [] (tset st :term nil)) {}))

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

; gitsigns
(let [signs (require :gitsigns)
      open (fn []
             (signs.blame)
             ;; 待つと安定する...
             (vim.defer_fn (fn []
                             (vim.cmd "wincmd w"))
               100))
      close (fn []
              (each [_ win (ipairs (vim.api.nvim_list_wins))]
                (when (and (vim.api.nvim_win_is_valid win)
                           (= (vim.api.nvim_buf_get_option (vim.api.nvim_win_get_buf win)
                                                           :filetype)
                              :gitsigns-blame))
                  (vim.api.nvim_win_close win true))))
      is_open (fn []
                (each [_ win (ipairs (vim.api.nvim_list_wins))]
                  (when (= (vim.api.nvim_buf_get_option (vim.api.nvim_win_get_buf win)
                                                        :filetype)
                           :gitsigns-blame)
                    (lua "return true")))
                false)]
  (M.register :blame {: open : close : is_open}))
