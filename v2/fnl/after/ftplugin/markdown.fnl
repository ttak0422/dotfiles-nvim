(each [key value (pairs {; :conceallevel 2
                         :number false
                         :foldcolumn :0
                         :listchars "tab:> "
                         :virtualedit :all})]
  (tset vim.opt_local key value))

(when (= (vim.fn.expand "%:e") :ipynb)
  ;; Add ipynb-specific keymaps here
  (do
    ((. (require :quarto) :activate))
    ((. (require :otter) :activate))
    (let [runner (require :quarto.runner)]
      (each [mode kvp (pairs {:n {:<LocalLeader>e ":MoltenEvaluateOperator<CR>"
                                  :<localleader>rr runner.run_cell
                                  :<localleader>ra runner.run_above
                                  :<localleader>rA runner.run_all
                                  :<localleader>rl runner.run_line
                                  ;; :<localleader>os ":noautocmd MoltenEnterOutput<CR>"
                                  ;; :<localleader>oh ":MoltenHideOutput<CR>"
                                  :<localleader>mi ":MoltenInit<CR>"
                                  :<localleader>md ":MoltenDelete<CR>"}
                              :v {:<localleader>r runner.run_range}})]
        (each [k v (pairs kvp)]
          (vim.keymap.set mode k v {:buf 0 :silent true}))))))
