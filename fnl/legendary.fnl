(let [M (require :legendary)
      keymaps []
      commands [{1 ":so $VIMRUNTIME/syntax/hitest.vim"
                 :description "enumerate highlight"}]
      functions []
      autocmds []]
  (M.setup {:include_builtin false
            :include_legendary_cmds false
            :col_separator_char ""
            : keymaps
            : commands
            : functions
            : autocmds}))
