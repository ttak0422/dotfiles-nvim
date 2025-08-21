(let [lir (require :lir)
      git (require :lir.git_status)
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
                :d actions.wipeout}
      float {:winblend 0
             :curdir_window {:enable false :highlight_dirname true}
             :win_opts #{:relative :cursor
                         :row 1
                         :col 0
                         :width 40
                         :height 12
                         :style :minimal
                         :border :single}
             :hide_cursor true}]
  (lir.setup {:show_hidden_files true : ignore : devicons : mappings : float})
  (git.setup {:show_ignored false}))
