(local claude (require :claudecode))

(local terminal {:split_side :right
                 :split_width_percentage 0.45
                 :provider :auto
                 :auto_close true})

(local keys [])

(claude.setup {: terminal : keys})
