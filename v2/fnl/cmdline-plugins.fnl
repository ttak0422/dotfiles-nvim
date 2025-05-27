(each [k v (pairs {:ignorecase true
                   :smartcase true
                   :hlsearch true
                   :incsearch true})]
  (tset vim.opt k v))

(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})]
  (each [_ k (ipairs [[:<Leader>/
                       #(vim.cmd "vimgrep //gj %")
                       (desc "register search results to qf")]
                      [:<Leader>?
                       #(vim.cmd "vimgrepadd //gj %")
                       (desc "add search results to qf")]])]
    (vim.keymap.set :n (. k 1) (. k 2) (or (. k 3) opts))))
