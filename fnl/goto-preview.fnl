(let [M (require :goto-preview)
      border :none
      post_close_hook nil]
  (M.setup {:height 20
            :width 120
            :default_mappings false
            :resizing_mappings false
            :focus_on_open true
            :dismiss_on_move false
            :debug false
            :opacity nil
            : border
            : post_close_hook}))
