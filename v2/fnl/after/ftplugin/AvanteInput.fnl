(let [opts {:buf 0 :silent true}]
  (vim.keymap.set :n :<Leader>p :<Cmd>PasteImage<CR> opts))
