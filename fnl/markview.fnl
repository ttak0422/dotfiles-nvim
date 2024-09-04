(let [M (require :markview)
      modes [:n :i :no :c]
      hybrid_modes [:i]
      callbacks {:on_enable (fn [_ win]
                              (tset (. vim.wo win) :conceallevel 3)
                              (tset (. vim.wo win) :concealcursor :nc))}]
  (M.setup {: modes : hybrid_modes : callbacks}))
