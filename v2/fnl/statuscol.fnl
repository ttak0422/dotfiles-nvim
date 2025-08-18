(local statuscol (require :statuscol))
(local builtin (require :statuscol.builtin))

(local segments [;{:text ["%s"] :maxwidth 1 :click "v:lua.ScSa"}
                 {:sign {:namespace [:gitsigns]
                         :maxwidth 1
                         :colwidth 1
                         :wrap true}}
                 {:text [builtin.foldfunc " "] :click "v:lua.ScFa"}
                 ;{:text [builtin.lnumfunc] :click "v:lua.ScLa"}
                 ])

(fn setup []
  (if (= vim.o.statuscolumn "")
      (statuscol.setup {: segments})))

(setup)

;; FIXME: 空bufferからの遷移時に上手く動作しないのでautocmdで対応する
(vim.api.nvim_create_autocmd [:BufReadPost] {:pattern ["*"] :callback setup})
