(let [opts {;; guifg, guibgの有効化
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
