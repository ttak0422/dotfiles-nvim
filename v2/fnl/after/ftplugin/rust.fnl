(let [opt {:silent true :buf 0}]
  (each [k v (pairs {:K #(vim.cmd.RustLsp [:hover :actions])})]
    (vim.keymap.set :n k v opt)))
