(let [M (require :stickybuf)
      get_auto_pin (fn [bufnr] (M.should_auto_pin bufnr))]
  (M.setup {: get_auto_pin}))
