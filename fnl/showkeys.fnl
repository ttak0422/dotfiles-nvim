(let [M (require :showkeys)
      winopts {:focusable false
               :relative :editor
               :style :minimal
               :border :single
               :height 1
               :row 1
               :col 0}
      keyformat {:<BS> "󰁮 "
                 :<CR> "󰘌"
                 :<Space> "󱁐"
                 :<Up> "󰁝"
                 :<Down> "󰁅"
                 :<Left> "󰁍"
                 :<Right> "󰁔"
                 :<PageUp> "Page 󰁝"
                 :<PageDown> "Page 󰁅"
                 :<M> :Alt
                 :<C> :Ctrl}]
  (M.setup {:maxkeys 8 :position :top-right : winopts : keyformat}))
