(local hydra (require :hydra))
(local float_opts {:border :single})
(local saved {})

(hydra.setup {:timeout false})

;; Resolve the module on use so the module hook can load draw-line lazily.
(fn draw [direction]
  ((. (require :draw-line) :draw) direction))

(fn box [style]
  (let [(ok err) ((. (require :draw-line) :box_visual) style)]
    (when (not ok)
      (vim.notify err vim.log.levels.WARN))))

(let [heads [[:H #(draw :h)]
             [:J #(draw :j)]
             [:K #(draw :k)]
             [:L #(draw :l)]
             [:r #(box :double) {:mode :x}]
             [:f #(box :single) {:mode :x}]
             [:v #(box :heavy) {:mode :x}]
             [:<Esc> nil {:desc :close :exit true}]]
      config {:invoke_on_body true
              :color :pink
              :on_enter (fn []
                          (set saved.win (vim.api.nvim_get_current_win))
                          (set saved.virtualedit vim.wo.virtualedit)
                          (set saved.selection vim.o.selection)
                          (vim.api.nvim_set_option_value :virtualedit :all {:scope :local})
                          (vim.api.nvim_set_option_value :selection :inclusive {}))
              :on_exit (fn []
                         (when (vim.api.nvim_win_is_valid saved.win)
                           (vim.api.nvim_set_option_value :virtualedit saved.virtualedit
                                                          {:win saved.win :scope :local}))
                         (vim.api.nvim_set_option_value :selection saved.selection {}))
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
