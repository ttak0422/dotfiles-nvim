(each [k v (pairs {:swapfile false :wrap false :conceallevel 3})]
  (tset vim.opt_local k v))

(let [map vim.keymap.set
      opts (fn [d] {:noremap true :silent true :buffer true :desc d})
      N [[:<LocalLeader>nn
          "<Plug>(neorg.dirman.new-note)"
          (opts " Create a new note")]]]
  (each [_ k (ipairs N)]
    (map :n (. k 1) (. k 2) (. k 3))))
