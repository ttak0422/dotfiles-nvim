(let [M (setmetatable {:builtin (require :statuscol.builtin)}
                      {:__index (require :statuscol)})
      segments [{:text ["%s"] :maxwidth 2 :click "v:lua.ScSa"}
                {:text [M.builtin.lnumfunc] :click "v:lua.ScLa"}
                {:text [" " M.builtin.foldfunc " "] :click "v:lua.ScFa"}]
      ft_ignore []]
  (M.setup {:setopt true :relculright false : ft_ignore : segments}))

;; 行数表示
(set vim.o.number true)
;; signcolumnのがたつきを無くす
(set vim.o.signcolumn :yes)
