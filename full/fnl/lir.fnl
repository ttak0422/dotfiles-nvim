(let [lir (require :lir)
      lirGit (require :lir.git_status)
      actions (require :lir.actions)
      ignore [:.DS_Store]
      devicons {:enable true :highlight_dirname true}
      mappings {:e actions.edit
                :<CR> actions.edit
                :L actions.edit
                :H actions.up
                :q actions.quit
                :<C-c> actions.quit
                :a actions.newfile
                :r actions.rename
                :d actions.delete}
      float {:winblend 0
             :curdir_window {:enable true :highlight_dirname true}
             :win_opts (fn []
                         (let [width (math.floor (/ vim.o.columns 2))
                               height (math.floor (/ vim.o.lines 2))]
                           {:relative :editor
                            : width
                            : height
                            :style :minimal
                            :border :none}))
             :hide_cursor true}]
  (lir.setup {:show_hidden_files true : ignore : devicons : mappings : float})
  (lirGit.setup {:show_ignored false}))
