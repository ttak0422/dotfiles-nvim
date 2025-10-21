(let [checkmate (require :checkmate)
      files [:todo :TODO :todo.md :TODO.md :*.todo :*.todo.md :scratch.md]
      keys {:<LocalLeader>tt {:rhs "<cmd>Checkmate toggle<CR>"
                              :desc "Toggle todo item"
                              :modes [:n :v]}
            :<LocalLeader>td {:rhs "<cmd>Checkmate check<CR>"
                              :desc "Set todo item as checked (done)"
                              :modes [:n :v]}
            :<LocalLeader>tu {:rhs "<cmd>Checkmate uncheck<CR>"
                              :desc "Set todo item as unchecked (not done)"
                              :modes [:n :v]}
            :<LocalLeader>tn {:rhs "<cmd>Checkmate create<CR>"
                              :desc "Create todo item"
                              :modes [:n :v]}
            :<LocalLeader>ta {:rhs "<cmd>Checkmate archive<CR>"
                              :desc "Archive checked/completed todo items (move to bottom section)"
                              :modes [:n]}}
      todo_states {:unchecked {:marker "□"}
                   :checked {:marker "✔"}
                   :in_progress {:marker "◐"
                                 :markdown "."
                                 :type :incomplete
                                 :order 50}
                   :cancelled {:marker ""
                               :markdown :c
                               :type :complete
                               :order 2}
                   :on_hold {:marker "⏸"
                             :markdown "/"
                             :type :inactive
                             :order 100}}
      show_todo_count true
      todo_count_formatter (fn [completed total]
                             (if (> total 4)
                                 (let [percent (* (/ completed total) 100)
                                       bar_length 10
                                       filled (math.floor (/ (* bar_length
                                                                percent)
                                                             100))]
                                   (.. (string.rep "◼︎" filled)
                                       (string.rep "◻︎"
                                                   (- bar_length filled))))
                                 (string.format "[%d/%d]" completed total)))]
  (checkmate.setup {: files
                    : keys
                    : todo_states
                    : show_todo_count
                    : todo_count_formatter}))
