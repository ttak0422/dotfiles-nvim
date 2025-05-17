(local wk (require :which-key))

(local win {:no_overlap true})

(local plugins {:presets {:operators false}})

(local keys {:Up "↑"
             :Down "↓"
             :Left "←"
             :Right "→"
             :C "󰘴 "
             :M "󰘵 "
             :D "󰘳 "
             :S "󰘶 "
             :CR "󰌑 "
             :Esc "󱊷 "
             :ScrollWheelDown "󱕐 "
             :ScrollWheelUp "󱕑 "
             :NL "󰌑 "
             :BS "󰁮 "
             :Space "_"
             :Tab "󰌒 "
             :F1 :F1
             :F2 :F2
             :F3 :F3
             :F4 :F4
             :F5 :F5
             :F6 :F6
             :F7 :F7
             :F8 :F8
             :F9 :F9
             :F10 :F10
             :F11 :F11
             :F12 :F12})

(wk.setup {: win : plugins : keys})
