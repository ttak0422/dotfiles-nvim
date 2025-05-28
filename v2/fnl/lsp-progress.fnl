(local progress (require :lsp-progress))

(fn format [messages]
  (if (> (length messages) 0)
      (table.concat messages " ") ""))

(progress.setup {:spin_update_time 400
                 :event_update_time_limit 500
                 :regular_internal_update_time 1000000000
                 :max_size 200
                 : format})
