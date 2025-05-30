(each [k v (pairs {;; タブでスペースを入力
                   :expandtab true
                   ;; タブ幅を2
                   :tabstop 2
                   ;; インデント幅
                   :shiftwidth 2
                   ;; 入力時に対応する括弧を強調
                   :showmatch true
                   ;; 補完の表示列
                   :ph 20
                   ;; 短径選択を寛容に
                   :virtualedit :block
                   ;; fold
                   :foldcolumn :1
                   :foldlevel 99
                   :foldlevelstart 99
                   :foldenable true})]
  (tset vim.o k v))

(vim.opt.fillchars:append {:eob " "
                           :fold " "
                           :foldopen "▾"
                           :foldsep " "
                           :foldclose "▸"})

(vim.opt.nrformats:append :unsigned)
