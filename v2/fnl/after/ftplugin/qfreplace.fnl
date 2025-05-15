(doto vim.opt_local
  (tset :buflisted false)
  (tset :bufhidden :delete))
