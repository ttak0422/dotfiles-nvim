(let [M (require :toggleterm)
      size (fn [term]
             (if (= term.direction :horizontal) (* vim.o.lines 0.35)
                 (* vim.o.columns 0.5)))]
  (M.setup {: size
            :shade_terminals false
            :auto_scroll false
            :start_in_insert true
            :winbar {:enabled false}}))
