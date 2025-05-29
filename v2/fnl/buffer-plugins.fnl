(each [k v (pairs {:updatetime 100})]
  (tset vim.opt k v))

(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})]
  (each [_ k (ipairs [[:<Leader>U
                       :<Cmd>UndotreeToggle<CR>
                       (desc " undotree")]])]
    (vim.keymap.set :n (. k 1) (. k 2) (or (. k 3) opts))))
