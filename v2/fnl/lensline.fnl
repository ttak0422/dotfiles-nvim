(local ll (require :lensline))

(ll.setup {:debounce_ms 1000
           :focused_debounce_ms 200
           :profiles [{:name :default
                       :style {:placement :inline :prefix "" :render :focused}}]})
