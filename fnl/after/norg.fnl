(each [k v (pairs {:swapfile false
                   :wrap false
                   :conceallevel 3
                   :concealcursor :n})]
  (tset vim.opt_local k v))

(let [map vim.keymap.set
      opts (fn [d] {:noremap false :silent true :buffer true :desc d})
      N [[:u
          (fn []
            ((. ((. (require :neorg.core.modules) :get_module) :core.esupports.metagen)
                :skip_next_update))
            (vim.api.nvim_feedkeys (vim.api.nvim_replace_termcodes :u<c-o> true
                                                                   false true)
                                   :n false))
          (opts " undo")]
         [:<C-r>
          (fn []
            ((. ((. (require :neorg.core.modules) :get_module) :core.esupports.metagen)
                :skip_next_update))
            (vim.api.nvim_feedkeys (vim.api.nvim_replace_termcodes :<c-r><c-o>
                                                                   true false
                                                                   true)
                                   :n false))
          (opts " redo")]
         [:<LocalLeader>nn
          "<Plug>(neorg.dirman.new-note)"
          (opts " Create a new note")]
         [:<LocalLeader>tu
          "<Plug>(neorg.qol.todo-items.todo.task-undone)"
          (opts " Mark as undone")]
         [:<LocalLeader>tp
          "<Plug>(neorg.qol.todo-items.todo.task-pending)"
          (opts " Mark as pending")]
         [:<LocalLeader>td
          "<Plug>(neorg.qol.todo-items.todo.task-done)"
          (opts " Mark as done")]
         [:<LocalLeader>th
          "<Plug>(neorg.qol.todo-items.todo.task-on-hold)"
          (opts " Mark as on hold")]
         [:<LocalLeader>tc
          "<Plug>(neorg.qol.todo-items.todo.task-cancelled)"
          (opts " Mark as on cancelled")]
         [:<LocalLeader>tr
          "<Plug>(neorg.qol.todo-items.todo.task-recurring)"
          (opts " Mark as recurring")]
         [:<LocalLeader>ti
          "<Plug>(neorg.qol.todo-items.todo.task-important)"
          (opts " Mark as important")]
         [:<LocalLeader>ta
          "<Plug>(neorg.qol.todo-items.todo.task-ambiguous)"
          (opts " Mark as ambiguous")]
         [:<C-Space>
          "<Plug>(neorg.qol.todo-items.todo.task-cycle)"
          (opts " Cycle task")]
         [:<CR>
          "<Plug>(neorg.esupports.hop.hop-link)"
          (opts " Jump to link")]
         ; [:<M-CR>
         ;  "<Plug>(neorg.esupports.hop.hop-link.vsplit)"
         ;  (opts " Jump to link (vsplit)")]
         [:<LocalLeader>lt
          "<Plug>(neorg.pivot.list.toggle)"
          (opts " Toggle (un)ordered list")]
         [:<LocalLeader>li
          "<Plug>(neorg.pivot.list.invert)"
          (opts " Invert (un)ordered list")]
         [:<LocalLeader>E
          "<Plug>(neorg.looking-glass.magnify-code-block)"
          (opts " Edit code block")]
         [:<LocalLeader>id
          "<Plug>(neorg.tempus.insert-date)"
          (opts " Insert date")]]
      I [[:<C-l>
          "<C-o><Plug>(neorg.telescope.insert_link)"
          (opts " Insert link")]
         [:<C-t>
          "<C-o><Plug>(neorg.promo.promote)"
          (opts " Promote object")]
         [:<C-d> "<C-o><Plug>(neorg.promo.demote)" (opts " Demote object")]
         ; [:<C-CR>
         ;  "<C-o><Plug>(neorg.itero.next-iteration)"
         ;  (opts " Continue object")]
         ]
      V [[">" "<Plug>(neorg.promo.promote.range)" (opts " Promote range")]
         ["<" "<Plug>(neorg.promo.demote.range)" (opts " Demote range")]]]
  (each [mode ks (pairs {:n N :i I :v V})]
    (each [_ k (ipairs ks)]
      (map mode (. k 1) (. k 2) (. k 3)))))
