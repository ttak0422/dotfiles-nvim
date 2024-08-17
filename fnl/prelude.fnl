;; options
(vim.loader.enable)
(each [k v (pairs {;; 言語メニューを無効にする
                   :langmenu :none
                   ;; shortmessオプションにsWIcCSを追加
                   :shortmess (.. vim.o.shortmess :sWcCS)
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
                   ;; statuslineを起動時に非表示
                   :laststatus 0
                   :foldlevel 99
                   :foldlevelstart 99})]
  (tset vim.o k v))

;; keymaps
(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")

(let [M vim.keymap.set
      C (fn [c] (.. :<cmd> c :<cr>))
      O {:noremap true :silent true}]
  ;; keymaps
  (each [_ K (ipairs [[:n
                       :<leader>
                       ":lua vim.cmd('doautocmd User TriggerLeader')<CR>"]
                      [[:n :v] ";" ":"]
                      [:n :<esc><esc> (C :nohl)]
                      [:n :j :gj]
                      [:n :k :gk]])]
    (M (. K 1) (. K 2) (. K 3) O))
  ;; term toggle keymaps
  (for [i 0 9]
    (M [:n :t :i] (.. :<C- i ">") (C (.. "TermToggle " i)) O)))

;; user events
(var specificFileEnterAutoCmd nil)

;; SpecificFileEnter
(let [A vim.api]
  (set specificFileEnterAutoCmd
       (A.nvim_create_autocmd :BufReadPost
                              {:callback (fn []
                                           (if (let [;; F vim.bo.filetype
                                                     B vim.bo.buftype]
                                                 (not (or (= B :prompt)
                                                          (= B :nofile))))
                                               (do
                                                 (A.nvim_exec_autocmds :User
                                                                       {:pattern :SpecificFileEnter})
                                                 (A.nvim_del_autocmd specificFileEnterAutoCmd))))})))

;; eager configs
(vim.cmd "colorscheme morimo")
((. (require :config-local) :setup) {:silent true})
