(let [M (setmetatable {:git (require :lir.git_status)
                       :actions (require :lir.actions)}
                      {:__index (require :lir)})
      ignore [:.DS_Store]
      devicons {:enable true :highlight_dirname true}
      mappings {:e M.actions.edit
                :<CR> M.actions.edit
                :L M.actions.edit
                :H M.actions.up
                :q M.actions.quit
                :<C-c> M.actions.quit
                :a M.actions.newfile
                :r M.actions.rename
                :d M.actions.delete}
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
  (M.setup {:show_hidden_files true : ignore : devicons : mappings : float})
  (M.git.setup {:show_ignored false}))
