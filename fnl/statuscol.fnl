(let [M (require :statuscol)
      builtin (require :statuscol.builtin)
      segments [{:text ["%s"] :maxwidth 2 :click "v:lua.ScSa"}
                {:text [builtin.lnumfunc] :click "v:lua.ScLa"}
                {:text [" " builtin.foldfunc " "] :click "v:lua.ScFa"}]]
  (M.setup {:setopt true :relculright false : segments}))
