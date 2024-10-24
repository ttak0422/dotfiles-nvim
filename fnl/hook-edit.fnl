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
                   ;; 補完オプション
                   ; :completeopt "menu,menuone,noselect"
                   :completeopt ""
                   ;; 短径選択を寛容に
                   :virtualedit :block})]
  (tset vim.o k v))

(each [k v (pairs {:foldmethod :expr
                   :foldexpr "v:lua.vim.treesitter.foldexpr()"})]
  (tset vim.opt k v))

(vim.opt.nrformats:append :unsigned)

(let [opts {:noremap true :silent true}
      ;; desc (fn [d] {:noremap true :silent true :desc d})
      cmd (fn [c] (.. :<cmd> c :<cr>))
      lcmd (fn [c] (cmd (.. "lua " c)))]
  (each [_ k (ipairs [[:gx (lcmd "require('open').open_cword()")]
                      [:<Leader>tz (cmd "NeoZoomToggle")]
                      [:<esc><esc> (cmd :nohl)]
                      [:j :gj]
                      [:k :gk]
                      [:<C-h> (lcmd "require('foldnav').goto_start()")]
                      [:<C-j> (lcmd "require('foldnav').goto_next()")]
                      [:<C-k> (lcmd "require('foldnav').goto_prev_start()")]
                      [:<C-l> (lcmd "require('foldnav').goto_end()")]])]
    (vim.keymap.set :n (. k 1) (. k 2) (or (. k 3) opts))))

;; clipboard (for ssh)
(let [osc52 (require :vim.ui.clipboard.osc52)
      paste (fn []
              [(vim.fn.split (vim.fn.getreg "") "\n") (vim.fn.getregtype "")])]
  ; (vim.opt.clipboard:append :unnamedplus)
  (if (not= (os.getenv :SSH_TTY) nil)
      (set vim.g.clipboard
           {:name "OSC 52"
            :copy {:+ (osc52.copy "+") :* (osc52.copy "*")}
            :paste {:+ paste :* paste}})))
