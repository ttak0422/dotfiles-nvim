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
               (= (vim.api.nvim_buf_get_option (vim.api.nvim_win_get_buf win)
                                               :filetype) ft))
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
(local toggleterm {})
(let [open_idx (fn [idx]
                 (let [terminal (require :toggleterm.terminal)
                       session (.. :vim/ idx)]
                   (-> (or (. toggleterm idx)
                           (let [t (terminal.Terminal:new {:cmd (.. "pterm open "
                                                                    session)
                                                           :close_on_exit false})]
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
