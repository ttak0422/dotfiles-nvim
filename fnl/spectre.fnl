(let [M (require :spectre)
      opts {:color_devicons false
            :live_update false
            :is_block_ui_break false
            :default {:find {:cmd :rg :options []} :replace {:cmd :sd}}}]
  (M.setup opts))
