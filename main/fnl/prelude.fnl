;; options
(let [opts {;; 言語メニューを無効にする
            :langmenu :none
            ;; shortmessオプションにsWIcCSを追加
            :shortmess (.. vim.o.shortmess :sWIcCS)
            ;; コマンドラインの高さを0に設定
            :cmdheight 0
            ;; guifg, guibgの有効化
            :termguicolors true
            ;; モードを非表示
            :showmode false
            ;; 起動時に行数を非表示表示
            :number false
            ;; signcolumnを起動時に非表示
            :signcolumn :no
            ;; tablineを起動時に非表示
            :showtabline 0
            :foldlevel 99
            :foldlevelstart 99}]
  (vim.loader.enable)
  (each [k v (pairs opts)]
    (tset vim.o k v)))

;; keymaps
(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")

(let [map vim.keymap.set
      opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})
      N [[:<leader> ":lua vim.cmd('doautocmd User TriggerLeader')<CR>"]
         [";" ":"]
         ]
      V [[";" ":"]
         ]]
  ;; normal mode keymaps
  (each [_ K (ipairs N)]
    (map :n (. K 1) (. K 2) (or (. K 3) opts)))
  (each [_ K (ipairs V)]
    (map :v (. K 1) (. K 2) (or (. K 3) opts))))
