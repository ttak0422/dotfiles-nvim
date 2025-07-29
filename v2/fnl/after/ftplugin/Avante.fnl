(set vim.opt_local.conceallevel 2)

(let [opts {:buffer true :silent true}]
  (each [_ key (ipairs [:i :a :o :A :I :O :s :S :c :C])]
    (vim.keymap.set :n key :<Nop> opts)))

(vim.cmd "normal! 0")
(vim.api.nvim_create_autocmd :WinEnter
                             {:buffer 0
                              :callback #(vim.schedule #(vim.cmd "normal! 0"))})
