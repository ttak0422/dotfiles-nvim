(local gc (require :garbage-day))

(gc.setup {:excluded_lsp_clients [:jdtls]
           :grace_period (* 60 30)
           :wakeup_delay 500})
