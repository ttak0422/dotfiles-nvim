(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})]
  (each [_ k (ipairs [[:<C-w>H "<Cmd>WinShift left<CR>"]
                      [:<C-w>J "<Cmd>WinShift down<CR>"]
                      [:<C-w>K "<Cmd>WinShift up<CR>"]
                      [:<C-w>L "<Cmd>WinShift right<CR>"]])]
    (vim.keymap.set :n (. k 1) (. k 2) (or (. k 3) opts))))
