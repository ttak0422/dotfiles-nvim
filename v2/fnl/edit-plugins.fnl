(macro cmd [c]
  `,(.. :<Cmd> c :<CR>))

(vim.cmd "
au FileType * setlocal formatoptions-=ro
au WinEnter * checktime
vnoremap ; :
nnoremap ; :
noremap gy \"+y
")

(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})
      dial (fn [direction mode]
             #((. (require :dial.map) :manipulate) direction mode))]
  (each [_ k (ipairs [[:<Leader>m
                       #((. (require :treesj) :toggle) {:split {:recursive false}})
                       (desc " join/split")]
                      [:<Leader>M
                       #((. (require :treesj) :toggle) {:split {:recursive true}})
                       (desc " join/split (recursive)")]
                      [:<Leader>O (cmd :Other)]
                      [:<C-h> #((. (require :foldnav) :goto_start))]
                      [:<C-j> #((. (require :foldnav) :goto_next))]
                      [:<C-k> #((. (require :foldnav) :goto_prev_start))]
                      [:<C-l> #((. (require :foldnav) :goto_end))]
                      [:<C-a>
                       #((. (require :dial.map) :manipulate) :increment :normal)]
                      [:<C-x>
                       #((. (require :dial.map) :manipulate) :decrement :normal)]
                      [:g<C-a>
                       #((. (require :dial.map) :manipulate) :increment
                                                             :gnormal)]
                      [:g<C-x>
                       #((. (require :dial.map) :manipulate) :decrement
                                                             :gnormal)]])]
    (vim.keymap.set :n (. k 1) (. k 2) (or (. k 3) opts)))
  (each [_ k (ipairs [[:<Leader>T ":Translate JA<CR>"]
                      [:<C-a>
                       #((. (require :dial.map) :manipulate) :increment :visual)]
                      [:<C-x>
                       #((. (require :dial.map) :manipulate) :decrement :visual)]
                      [:g<C-a>
                       #((. (require :dial.map) :manipulate) :increment
                                                             :gvisual)]
                      [:g<C-x>
                       #((. (require :dial.map) :manipulate) :decrement
                                                             :gvisual)]])]
    (vim.keymap.set :x (. k 1) (. k 2) (or (. k 3) opts))))
