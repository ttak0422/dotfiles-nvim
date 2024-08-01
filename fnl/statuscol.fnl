(let [M (setmetatable {:builtin (require :statuscol.builtin)}
                      {:__index (require :statuscol)})
      segments [{:text ["%s"] :maxwidth 2 :click "v:lua.ScSa"}
                {:text [M.builtin.lnumfunc] :click "v:lua.ScLa"}
                {:text [" " M.builtin.foldfunc " "] :click "v:lua.ScFa"}]]
  (M.setup {:setopt true :relculright false : segments}))
