(let [cmd vim.api.nvim_create_user_command]
  (cmd :SearchToQf (fn [opts]
                     (let [command (if opts.bang :vimgrepadd :vimgrep)
                           pattern "//gj %"]
                       (vim.cmd (.. command " " pattern))))
       {:bang true}))

(let [opts {;; 大文字・小文字を区別しない
            :ignorecase true
            ;; 大文字検索時に通常検索
            :smartcase true
            ;; 検索結果をハイライトする
            :hlsearch true
            ;; インクリメンタル検索
            :incsearch true}]
  (each [k v (pairs opts)]
    (tset vim.o k v)))

(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})
      cmd (fn [c] (.. :<cmd> c :<cr>))
      N [[:<leader>/
          (cmd :SearchToQf)
          (desc "register search results to quickfix")]
         [:<leader>?
          (cmd :SearchToQf! (desc "add search results to quickfix"))]]]
  (each [_ k (ipairs N)]
    (vim.keymap.set :n (. k 1) (. k 2) (or (. k 3) opts))))

(vim.cmd "
  cabbrev <expr> r getcmdtype() .. getcmdline() ==# ':r' ? [getchar(), ''][1] .. '%s//g<Left><Left>' : (getcmdline() ==# ''<,'>r' ?  [getchar(), ''][1] .. 's//g<Left><Left>' : 'r')
")
