(let [M (require :markview)
      modes [:n :no :c]
      hybrid_modes [:n]
      callbacks {:on_enable (fn [_ win]
                              (tset (. vim.wo win) :conceallevel 3)
                              (tset (. vim.wo win) :concealcursor :c))}]
  (M.setup {: modes : hybrid_modes : callbacks}))
