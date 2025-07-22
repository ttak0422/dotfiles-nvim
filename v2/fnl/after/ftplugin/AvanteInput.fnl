(let [opts {:buffer true :silent true}]
  (vim.keymap.set :n :<Leader>p :<Cmd>PasteImage<CR> opts))
