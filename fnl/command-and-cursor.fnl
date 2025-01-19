(let [M (require :command_and_cursor)]
  (M.setup {:hl_group :TermCursor
            :hl_priority 300
            :inclusive true
            :debug_position false}))
