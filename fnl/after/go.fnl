(set vim.opt_local.expandtab false)

;; depends goimpl
(let [opts (fn [d] {:noremap false :silent true :buffer true :desc d})]
  (each [mode ks (pairs {:n [[:<LocalLeader>fi
                              (fn []
                                ((-> (require :telescope)
                                     (. :extensions)
                                     (. :goimpl)
                                     (. :goimpl))))
                              (opts " generate stub for I/F")]]})]
    (each [_ k (ipairs ks)]
      (vim.keymap.set mode (. k 1) (. k 2) (. k 3)))))
