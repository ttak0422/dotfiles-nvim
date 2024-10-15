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
                   ;; 起動時に行数を表示
                   :number true
                   ;; 起動時にfoldcolumを表示
                   :foldcolumn :1
                   ;; signcolumnを起動時に表示
                   :signcolumn :yes
                   ;; tablineを起動時に非表示
                   :showtabline 0
                   ; statuslineを起動時に非表示
                   :laststatus 0
                   :foldlevel 99
                   :foldlevelstart 99
                   :splitkeep :screen})]
  (tset vim.o k v))

;; keymaps
(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")

(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})
      cmd (fn [c] (.. :<cmd> c :<cr>))
      lcmd (fn [c] (cmd (.. "lua " c)))
      mk_toggle ((fn []
                   (let [state {:open? false :pre_id nil}]
                     (fn [id mod args]
                       (fn []
                         (if (not= state.pre_id id)
                             (do
                               ((. (require :toolwindow) :open_window) mod args)
                               (tset state :open? true))
                             (if state.open?
                                 (do
                                   ((. (require :toolwindow) :close))
                                   (tset state :open? false))
                                 (do
                                   ((. (require :toolwindow) :open_window) mod
                                                                           args)
                                   (tset state :open? true))))
                         (tset state :pre_id id))))))]
  ;; leader keymaps
  (each [_ K (ipairs [;; finder
                      [:ff
                       (cmd "Telescope live_grep_args")
                       (desc "search by content")]
                      [:fF (cmd "Telescope ast_grep") (desc "search by AST")]
                      [:ft
                       (cmd "Telescope sonictemplate templates")
                       (desc "search templates")]
                      [:fh (cmd :Legendary) (desc "Search command palette")]
                      [:H
                       (lcmd "require('harpoon').ui:toggle_quick_menu(require('harpoon'):list(),{border='none'})")
                       (desc "Show registered file")]
                      [:ha
                       (lcmd "require('harpoon'):list():add()")
                       (desc "Register file")]
                      [:fp
                       (cmd "Ddu -name=fd file_fd")
                       (desc "search by file name")]
                      [:fP
                       (cmd "Ddu -name=ghq ghq")
                       (desc "search repo (ghq)")]
                      [:fru
                       (cmd "Ddu -name=mru mru")
                       (desc "MRU (Most Recently Used files)")]
                      [:frw
                       (cmd "Ddu -name=mrw mrw")
                       (desc "MRW (Most Recently Written files)")]
                      [:frr
                       (cmd "Ddu -name=mrr mrr")
                       (desc "MRR (Most Recent git Repositories)")]
                      ;; mark
                      [:mq
                       (cmd :MarksQFListBuf)
                       (desc "marks in current buffer")]
                      [:mQ
                       (cmd :MarksQFListGlobal)
                       (desc "marks in all buffer")]
                      ;; undo
                      [:U (cmd :UndotreeToggle (desc "toggle undotree"))]
                      ;; neorg
                      [:nn
                       (cmd "Neorg journal today")
                       (desc "Enter Neorg (today journal)")]
                      [:no (cmd "Neorg toc") (desc "Show Neorg TOC")]
                      [:N (cmd :Neorg) (desc "Enter Neorg")]
                      [:fn
                       (cmd :NeorgFuzzySearch)
                       (desc "find Neorg linkable")]
                      ;; git
                      [:G (cmd :Neogit) (desc " client")]
                      [:gb (cmd :ToggleGitBlame) (desc " blame")]
                      ;; filter
                      [:tb
                       (lcmd "require('lir.float').toggle()")
                       (desc "Toggle lir")]
                      [:tB (lcmd "require('oil').open()") (desc "Toggle oil")]
                      ;; buffer
                      [:q (cmd :BufDel) (desc "close buffer")]
                      [:Q (cmd :BufDelAll) (desc "close all buffers")]
                      ;; tab
                      [:A (cmd :tabclose)]
                      ;; toggle
                      [:ts (cmd "Screenkey toggle") (desc "toggle screenkey")]
                      [:tc (cmd :ColorizerToggle) (desc "toggle colorizer")]
                      [:tt (cmd :NoNeckPain) (desc "toggle no neck pain")]
                      [:tm
                       (lcmd "require('codewindow').toggle_minimap()")
                       (desc "toggle minimap")]
                      [:tj
                       (cmd "lua require('treesj').toggle({ split = { recursive = false }})")
                       (desc "toggle split/join")]
                      [:tJ
                       (cmd "lua require('treesj').toggle({ split = { recursive = true }})")
                       (desc "toggle recursive split/join")]
                      [:tq (mk_toggle 1 :qf nil) (desc "toggle quickfix")]
                      [:td
                       (mk_toggle 2 :trouble
                                  {:mode :diagnostics :filter {:buf 0}})
                       (desc "toggle diagnostics (document)")]
                      [:tD
                       (mk_toggle 3 :trouble {:mode :diagnostics})
                       (desc "toggle diagnostics (workspace)")]])]
    (vim.keymap.set :n (.. :<Leader> (. K 1)) (. K 2) (or (. K 3) opts)))
  (each [_ K (ipairs [; [:T (cmd :Translate)]
                      [:R (cmd :FlowRunSelected)]])]
    (vim.keymap.set :v (. K 1) (. K 2) (or (. K 3) opts)))
  ;; term toggle keymaps
  (for [i 0 9]
    (vim.keymap.set [:n :t :i] (.. :<C- i ">")
                    (mk_toggle (+ 4 i) :terminal {:idx i}) opts)))

;; eager configs
(vim.cmd "colorscheme morimo")
((. (require :config-local) :setup) {:silent true})
