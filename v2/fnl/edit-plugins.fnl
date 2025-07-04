(vim.cmd "
au FileType * setlocal formatoptions-=ro
au WinEnter * checktime
vnoremap ; :
nnoremap ; :
")

(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})]
  (each [_ k (ipairs [[:j :gj]
                      [:k :gk]
                      [:<Leader>m
                       #((. (require :treesj) :toggle) {:split {:recursive false}})
                       (desc " join/split")]
                      [:<Leader>M
                       #((. (require :treesj) :toggle) {:split {:recursive true}})
                       (desc " join/split (recursive)")]
                      [:<C-h> #((. (require :foldnav) :goto_start))]
                      [:<C-j> #((. (require :foldnav) :goto_next))]
                      [:<C-k> #((. (require :foldnav) :goto_prev_start))]
                      [:<C-l> #((. (require :foldnav) :goto_end))]])]
    (vim.keymap.set :n (. k 1) (. k 2) (or (. k 3) opts)))
  (each [_ k (ipairs [[:<Leader>T ":Translate JA<CR>"]])]
    (vim.keymap.set :v (. k 1) (. k 2) (or (. k 3) opts))))
