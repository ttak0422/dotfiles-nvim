(let [M (require :toggleterm)
      size (fn [term]
             (if (= term.direction :horizontal) (* vim.o.lines 0.5)
                 (* vim.o.columns 0.5)))
      float_opts {:border :single
                  :width #(math.floor (* vim.o.columns 0.95))
                  :height #(math.floor (* vim.o.lines 0.9))
                  :title_pos :center}]
  (M.setup {: size
            : float_opts
            :shade_terminals false
            :auto_scroll false
            :start_in_insert true
            :winbar {:enabled false}}))
