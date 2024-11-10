(let [M (require :statuscol)
      builtin (require :statuscol.builtin)
      segments [{:text ["%s"] :maxwidth 2 :click "v:lua.ScSa"}
                {:text [builtin.lnumfunc] :click "v:lua.ScLa"}
                {:text [" " builtin.foldfunc " "] :click "v:lua.ScFa"}]]
  ;; FIXME: 空bufferからの遷移時に上手く動作しないのでautocmdで対応する
  (vim.api.nvim_create_autocmd [:BufReadPost]
                               {:pattern ["*"]
                                :callback (fn []
                                            (if (= vim.o.statuscolumn "")
                                                (M.setup {:setopt true
                                                          :relculright false
                                                          : segments})))}))
