(let [M (require :oil)]
  (M.setup {:default_file_explorer false
            :columns [:icon :permissions :size :mtime]
            :delete_to_trash true
            :use_default_keymaps false
            :lsp_file_methods {:timeout_ms 5000}
            :view_options {:show_hidden true
                           :is_hidden_file (fn [_name _bufnr] false)
                           :is_always_hidden (fn [_name _bufnr] false)
                           :sort [[:type :asc] [:name :asc]]}
            :keymaps {:g? :actions.show_help
                      :<CR> :actions.select
                      :e :actions.select
                      :<C-v> :actions.select_vsplit
                      :<C-s> :actions.select_split
                      :<C-t> :actions.select_tab
                      :<C-p> :actions.preview
                      :q :actions.close
                      :<C-c> :actions.close
                      :R :actions.refresh
                      :H :actions.parent
                      :L :actions.select}
            :keymaps_help {:border :none}}))
