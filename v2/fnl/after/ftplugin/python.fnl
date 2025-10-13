(when (= (vim.fn.expand "%:e") :ipynb)
  ;; Add ipynb-specific keymaps here
  (each [mode kvp (pairs {:n {:<LocalLeader>e ":MoltenEvaluateOperator<CR>"
                              :<localleader>rr ":MoltenReevaluateCell<CR>"
                              :<localleader>os ":noautocmd MoltenEnterOutput<CR>"
                              :<localleader>oh ":MoltenHideOutput<CR>"
                              :<localleader>mi ":MoltenInit<CR>"
                              :<localleader>md ":MoltenDelete<CR>"}
                          :v {:<localleader>r ":<C-u>MoltenEvaluateVisual<CR>gv"}})]
    (each [k v (pairs kvp)]
      (vim.keymap.set mode k v {:buffer true :silent true}))))
