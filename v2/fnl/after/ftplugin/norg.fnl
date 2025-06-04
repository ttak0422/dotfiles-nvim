(macro leader [...]
  `,(.. :<Leader> ...))

(macro local_leader [...]
  `,(.. :<LocalLeader> ...))

(macro cmd [c]
  `,(.. :<Cmd> c :<CR>))

(macro plug [p]
  `,(.. "<Plug>(" p ")"))

;; options
(each [k v (pairs {:swapfile false
                   :wrap false
                   :conceallevel 3
                   :concealcursor :n})]
  (tset vim.opt_local k v))

(vim.opt_local.iskeyword:append ["$" "/"])

;; keymaps
(local opts {:noremap true :silent true})
(fn desc [d] {:noremap false :silent true :buffer true :desc d})
(fn skip_next_update []
  ((. ((. (require :neorg.core.modules) :get_module) :core.esupports.metagen)
      :skip_next_update)))

(fn feed_keys [ks]
  (-> (vim.api.nvim_replace_termcodes ks true false true)
      (vim.api.nvim_feedkeys :n false)))

(local normal [; for auto save
               [:u
                (fn [] (skip_next_update)
                  (feed_keys :u<C-o>))
                (desc " undo")]
               [:<C-r>
                (fn []
                  (skip_next_update)
                  (feed_keys :<C-r><C-o>))
                (desc " redo")]
               [(local_leader :nn)
                (plug :neorg.dirman.new-note)
                (desc " Create a new note")]
               [(local_leader :no) (cmd "Neorg toc") (desc " TOC")]
               [(local_leader :tu)
                (plug :neorg.qol.todo-items.todo.task-undone)
                (desc " Mark as undone")]
               [(local_leader :tp)
                (plug :neorg.qol.todo-items.todo.task-pending)
                (desc " Mark as pending")]
               [(local_leader :td)
                (plug :neorg.qol.todo-items.todo.task-done)
                (desc " Mark as done")]
               [(local_leader :th)
                (plug :neorg.qol.todo-items.todo.task-on-hold)
                (desc " Mark as on hold")]
               [(local_leader :tc)
                (plug :neorg.qol.todo-items.todo.task-cancelled)
                (desc " Mark as on cancelled")]
               [(local_leader :tr)
                (plug :neorg.qol.todo-items.todo.task-recurring)
                (desc " Mark as recurring")]
               [(local_leader :ti)
                (plug :neorg.qol.todo-items.todo.task-important)
                (desc " Mark as important")]
               [(local_leader :ta)
                (plug :neorg.qol.todo-items.todo.task-ambiguous)
                (desc " Mark as ambiguous")]
               [:<C-Space>
                (plug :neorg.qol.todo-items.todo.task-cycle)
                (desc " Cycle task")]
               [:<CR>
                (plug :neorg.esupports.hop.hop-link)
                (desc " Jump to link")]
               [(local_leader :lt)
                (plug :neorg.pivot.list.toggle)
                (desc " Toggle (un)ordered list")]
               [(local_leader :li)
                (plug :neorg.pivot.list.invert)
                (desc " Invert (un)ordered list")]
               [(local_leader :E)
                (plug :neorg.looking-glass.magnify-code-block)
                (desc " Edit code block")]
               [(local_leader :id)
                (plug :neorg.tempus.insert-date)
                (desc " Insert date")]
               [(local_leader :O)
                ":execute 'Neorg export to-file ' . expand('%:r') . '.md'<cr>"
                (desc " Export as markdown")]])

(local insert [; [:<C-l>
               ;  "<C-o><Plug>(neorg.telescope.insert_file_link)"
               ;  (desc " Insert link")]
               [:<C-t>
                "<C-o><Plug>(neorg.promo.promote)"
                (desc " Promote object")]
               [:<C-d>
                "<C-o><Plug>(neorg.promo.demote)"
                (desc " Demote object")]])

(local visual [[">"
                (plug :neorg.promo.promote.range)
                (desc " Promote range")]
               ["<" (plug :neorg.promo.demote.range) (desc " Demote range")]
               [(local_leader :C)
                ":Neorg export to-clipboard markdown<cr>"
                (desc " Export to clipboard")]])

(each [mode ks (pairs {:n normal :i insert :v visual})]
  (each [_ k (ipairs ks)]
    (vim.keymap.set mode (. k 1) (. k 2) (or (. k 3) opts))))
