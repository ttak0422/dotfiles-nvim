(local hydra (require :hydra))
(local float_opts {:border :single})

(hydra.setup {:timeout false})

(let [heads [[:H "<C-v>h:VBox<CR>"]
             [:J "<C-v>j:VBox<CR>"]
             [:K "<C-v>k:VBox<CR>"]
             [:L "<C-v>l:VBox<CR>"]
             [:r ":VBoxD<CR>" {:mode :v}]
             [:f ":VBox<CR>" {:mode :v}]
             [:v ":VBoxH<CR>" {:mode :v}]
             [:<Esc> nil {:desc :close :exit true}]]
      config {:invoke_on_body true
              :color :pink
              :on_enter #(vim.cmd "setlocal ve=all")
              :on_exit #(vim.cmd "setlocal ve=")
              :hint {:type :window :position :bottom-right : float_opts}}
      hint ":Move    Select region with <C-v>
-------  -------------------------
   _K_     _r_: surround double
 _H_   _L_   _f_: surround single
   _J_     _v_: surround bold"]
  (hydra {:name "Draw Diagram"
          :mode :n
          :body :<Leader>V
          : heads
          : config
          : hint}))
