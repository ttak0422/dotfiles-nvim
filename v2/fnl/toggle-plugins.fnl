;; TODO: 安定化
(local toggler (require :toggler))

(fn with_keep_window [f]
  (fn []
    (let [win (vim.api.nvim_get_current_win)]
      (f)
      (if (vim.api.nvim_win_is_valid win)
          (vim.api.nvim_set_current_win win)))))

; NOTE: toggler側でパラメータとして提供できそう
(fn filetype_exists [ft]
  (each [_ win (ipairs (vim.api.nvim_list_wins))]
    (when (and (vim.api.nvim_win_is_valid win)
               (= (vim.api.nvim_get_option_value :filetype
                                                 {:buf (vim.api.nvim_win_get_buf win)})
                  ft))
      (lua "return true")))
  false)

;;; quickfix ;;;
; (toggler.register :qf {:open (with_keep_window (fn [] (vim.cmd :copen)))
;                        :close (fn [] (vim.cmd :cclose))
;                        :is_open (fn []
;                                   (not= (-> (vim.fn.getqflist {:winid 0})
;                                             (. :winid))
;                                         0))})
(var qf? false)
(toggler.register :qf {:open (with_keep_window #(if (not qf?)
                                                    (do
                                                      (vim.cmd :copen)
                                                      (set qf? true))))
                       :close #(if qf?
                                   (do
                                     (vim.cmd :cclose)
                                     (set qf? false)))
                       :is_open #(let [is_open (filetype_exists :qf)]
                                   (set qf? is_open)
                                   is_open)})

;;; harpoon ;;;
(var harpoon? false)
(let [toggle #(let [h (require :harpoon)]
                (h.ui:toggle_quick_menu (h:list) {:title "" :border :single}))]
  (toggler.register :harpoon
                    {:open #(if (not harpoon?) (toggle))
                     :close #(if harpoon? (toggle))
                     :is_open #(let [is_open (filetype_exists :harpoon)]
                                 (set harpoon? is_open)
                                 is_open)}))

;;; trouble ;;;
(let [st {:recent_type nil}
      mk_open (fn [opt type]
                (with_keep_window (fn []
                                    ((. (require :trouble) :open) opt)
                                    (tset st :recent_type type))))
      close #(case (. package.loaded :trouble)
               t (t.close))
      mk_is_open (fn [type]
                   #(case (. package.loaded :trouble)
                      t (and (t.is_open) (= st.recent_type type))
                      _ false))]
  (toggler.register :trouble-doc
                    {:open (mk_open {:mode :diagnostics :filter {:buf 0}} :doc)
                     : close
                     :is_open (mk_is_open :doc)})
  (toggler.register :trouble-ws
                    {:open (mk_open {:mode :diagnostics} :ws)
                     : close
                     :is_open (mk_is_open :ws)}))

;;; terminal ;;;
(local terminal-windows {})
(let [current-tab #(vim.api.nvim_get_current_tabpage)
      float-config (fn []
                     (let [width (math.max 1 (math.floor (* vim.o.columns 0.95)))
                           height (math.max 1 (math.floor (* (- vim.o.lines 2) 0.95)))]
                       {:relative :editor
                        :row (math.floor (/ (- vim.o.lines height) 2))
                        :col (math.floor (/ (- vim.o.columns width) 2))
                        : width : height :style :minimal :border :single}))
      tab-terminals (fn [tab]
                      (or (. terminal-windows tab)
                          (let [terms {}]
                            (tset terminal-windows tab terms)
                            terms)))
      get_idx (fn [idx]
                (. (tab-terminals (current-tab)) idx))
      is_open_idx (fn [idx]
                    (let [term (get_idx idx)]
                      (and term (vim.api.nvim_win_is_valid term.win)
                           (= (vim.api.nvim_win_get_buf term.win) term.buf))))
      open_idx (fn [idx]
                 (let [tab (current-tab)
                       terms (tab-terminals tab)
                       session (.. :vim_tab tab :_idx idx)]
                   (if (is_open_idx idx)
                       (vim.api.nvim_set_current_win (. (. terms idx) :win))
                       (let [buf (vim.api.nvim_create_buf false true)
                             _ (tset vim.bo buf :bufhidden :wipe)
                             win (vim.api.nvim_open_win buf true (float-config))]
                         (tset terms idx {: win})))
                   ;; The managed plugin owns size authority and history reset ACKs.
                   ((. (require :pterm) :open) session)
                   (tset (. terms idx) :buf (vim.api.nvim_get_current_buf))))
      close_idx (fn [idx]
                  (when (is_open_idx idx)
                    (vim.api.nvim_win_close (. (get_idx idx) :win) true)))]
  (vim.api.nvim_create_autocmd :VimResized
                               {:group (vim.api.nvim_create_augroup :pterm_terminal_floats {:clear true})
                                :callback (fn []
                                            (each [_ terms (pairs terminal-windows)]
                                              (each [_ term (pairs terms)]
                                                (when (and (vim.api.nvim_win_is_valid term.win)
                                                           (= (vim.api.nvim_win_get_buf term.win) term.buf))
                                                  (vim.api.nvim_win_set_config term.win (float-config))))))})
  (for [i 0 9]
    (toggler.register (.. :term i)
                      {:open #(open_idx i)
                       :close #(close_idx i)
                       :is_open #(is_open_idx i)})))

;;; dap-ui ;;;
(var dapui nil)
(let [open (fn []
             (if (= dapui nil)
                 (set dapui (require :dapui)))
             (dapui:open {:reset true}))
      close #(if (not= dapui nil)
                 (dapui.close))
      is_open (fn []
                (each [_ win (ipairs (. (require :dapui.windows) :layouts))]
                  (if (win:is_open)
                      (lua "return true")))
                false)]
  (toggler.register :dapui {: open : close : is_open}))

;;; aerial ;;;
(var aerial nil)
(let [open (fn []
             (if (= aerial nil)
                 (set aerial (require :aerial)))
             (aerial.open))
      close #(if (not= aerial nil)
                 (aerial.close))
      is_open #(filetype_exists :aerial)]
  (toggler.register :aerial {: open : close : is_open}))
