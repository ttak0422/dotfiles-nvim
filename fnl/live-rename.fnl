(let [M (require :live-rename)
      keys {:submit [[:n :<cr>] [:v :<cr>] [:i :<cr>]]
            :cancel [[:n :<esc>] [:n :q] [:n :<C-c>]]}
      hl {:current :CurSearch :others :Search}]
  (M.setup {:prepare_rename true :request_timeout 5000 : keys : hl}))
