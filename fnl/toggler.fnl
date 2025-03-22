(local M (require :toggler))

(local map vim.keymap.set)
(local create_command vim.api.nvim_create_user_command)

; helper functions
(fn with_keep_window [f]
  (fn []
    (let [win (vim.api.nvim_get_current_win)]
      (f)
      (vim.api.nvim_set_current_win win))))

(fn filetype_exists [ft]
  (each [_ win (ipairs (vim.api.nvim_list_wins))]
    (when (= (vim.api.nvim_buf_get_option (vim.api.nvim_win_get_buf win)
                                          :filetype) ft)
      (lua "return true")))
  false)

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
                       _ (let [session (.. :VIM idx)
                               ; WIP: on_create (fn [term] (term:send (.. "zellij -s " session " --layout " zellij_layout))
                               term (-> (require :toggleterm.terminal)
                                        (. :Terminal)
                                        (: :new
                                           {:direction :float
                                            :float_opts {:border :none}
                                            :cmd (.. "zellij attach " session
                                                     " --create")}))]
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
(var gitu nil)
(var gitu_dir nil)
(let [is_open (fn []
                (-?> gitu
                     (: :is_open)))
      close (fn []
              (-?> gitu
                   (: :close)))
      on_create (fn [term]
                  (map :t :<ESC> :i<ESC>
                       {:buffer term.bufnr :noremap true :silent true})
                  (vim.api.nvim_create_autocmd :BufLeave
                                               {:buffer term.bufnr
                                                :callback close}))
      float_opts {:height (fn [] (math.floor (* vim.o.lines 0.9)))
                  :width (fn [] (math.floor (* vim.o.columns 0.9)))}
      open (fn []
             (if (= gitu_dir nil)
                 (set gitu_dir (vim.fn.getcwd))
                 (let [cwd (vim.fn.getcwd)]
                   (if (not= gitu_dir cwd)
                       (do
                         (set gitu_dir cwd)
                         (set gitu nil)))))
             (if (= gitu nil)
                 (set gitu (-> (require :toggleterm.terminal)
                               (. :Terminal)
                               (: :new
                                  {:direction :float
                                   :cmd :gitu
                                   :shade_terminals false
                                   : on_create
                                   : float_opts}))))
             (gitu:open)
             (vim.cmd :startinsert))]
  (M.register :gitu {: open : close : is_open})
  (create_command :ClearGitu (fn [] (set gitu nil)) {}))

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
      is_open (fn [] (filetype_exists :gitsigns-blame))]
  (M.register :blame {: open : close : is_open}))

; dap
(var dapui nil)
(let [open (fn []
             (if (= dapui nil)
                 (set dapui (require :dapui)))
             (dapui:open {:reset true}))
      close (fn []
              (if (not= dapui nil)
                  (dapui.close)))
      is_open (fn []
                (each [_ win (ipairs (. (require :dapui.windows) :layouts))]
                  (if (win:is_open)
                      (lua "return true")))
                false)]
  (M.register :dapui {: open : close : is_open}))

; neotest
(var neotest nil)
(let [open (fn []
             (if (= neotest nil)
                 (set neotest (require :neotest)))
             (neotest.output_panel.open))
      close (fn []
              (if (not= neotest nil)
                  (neotest.output_panel.close)))
      is_open (fn [] (filetype_exists :neotest-output-panel))]
  (M.register :neotest-output {: open : close : is_open}))

(let [open (fn []
             (if (= neotest nil)
                 (set neotest (require :neotest))
                 (neotest.summary.open)))
      close (fn []
              (if (not= neotest nil)
                  (neotest.summary.close)))
      is_open (fn []
                (filetype_exists :neotest-summary))]
  (M.register :neotest-summary {: open : close : is_open}))

; aerial
(var aerial nil)
(let [open (fn []
             (if (= aerial nil)
                 (set aerial (require :aerial)))
             (aerial.open))
      close (fn []
              (if (not= aerial nil)
                  (aerial.close)))
      is_open (fn [] (filetype_exists :aerial))]
  (M.register :aerial {: open : close : is_open}))
