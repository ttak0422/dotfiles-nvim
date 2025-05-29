(each [k v (pairs {:direnv_auto 1 :direnv_silent_load 0})]
  (tset vim.g k v))
