(let [M (require :legendary)
      keymaps []
      commands [{1 ":so $VIMRUNTIME/syntax/hitest.vim"
                 :description "Show highlights"}]
      funcs [{1 Snacks.notifier.show_history
              :description "Show notification history"}]
      autocmds []]
  (M.setup {:include_builtin false
            :include_legendary_cmds false
            :col_separator_char ""
            : keymaps
            : commands
            : funcs
            : autocmds}))
