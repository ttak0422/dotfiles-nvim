(let [M (require :toggleterm)
      size (fn [term]
             (if (= term.direction :horizontal) (* vim.o.lines 0.35)
                 (* vim.o.columns 0.5)))
      float_opts {:border :single
                  :width (fn [] (math.min vim.o.columns 150))
                  :height (fn [] (math.floor (* vim.o.lines 0.8)))
                  ; :row  <value>
                  ; :col  <value>
                  ; :winblend 3
                  ; zindex  <value>
                  :title_pos :center}]
  (M.setup {: size
            : float_opts
            :shade_terminals false
            :auto_scroll false
            :start_in_insert true
            :winbar {:enabled false}}))
