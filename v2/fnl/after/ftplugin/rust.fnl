(let [opt {:silent true :buffer true}]
  (each [k v (pairs {:K #(vim.cmd.RustLsp [:hover :actions])})]
    (vim.keymap.set :n k v opt)))
