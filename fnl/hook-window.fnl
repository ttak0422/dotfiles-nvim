(let [opts {:noremap true :silent true}
      cmd (fn [c] (.. :<cmd> c :<cr>))
      desc (fn [d] {:noremap true :silent true :desc d})
      N [[:<C-w>H (cmd "WinShift left")]
         [:<C-w>J (cmd "WinShift down")]
         [:<C-w>K (cmd "WinShift up")]
         [:<C-w>L (cmd "WinShift right")]
         [:<C-w>e
          (fn []
            ((. (require :smart-splits) :start_resize_mode)))
          (desc "resize mode")]
         [:<C-w>p
          (fn []
            ((. (require :nvim-window) :pick)))
          (desc "pick window")]
         [:<C-w><CR> (cmd :DetourCurrentWindow)]]]
  (each [_ k (ipairs N)]
    (vim.keymap.set :n (. k 1) (. k 2) (or (. k 3) opts))))
