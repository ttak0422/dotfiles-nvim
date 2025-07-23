(each [key value (pairs {:conceallevel 2
                         :number false
                         :signcolumn "no"
                         :foldcolumn "0"
                         })]
  (tset vim.opt_local key value))
