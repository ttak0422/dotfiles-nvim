;; options
(vim.loader.enable)
(vim.cmd "language messages en_US.UTF-8")

(each [k v (pairs {:langmenu :none
                   :shortmess (.. vim.o.shortmess :sWcS)
                   :cmdheight 0
                   :termguicolors true
                   :number true
                   ;; signcolumnを起動時に表示
                   :signcolumn :yes
                   ;; tablineを起動時に非表示
                   :showtabline 0
                   ; statuslineを起動時に非表示
                   :laststatus 0
                   :foldlevel 99
                   :foldlevelstart 99
                   :foldcolumn :1
                   :splitkeep :screen
                   :wrap false
                   :completeopt []})]
  (tset vim.opt k v))

(each [k v (pairs {:mapleader " "
                   :maplocalleader ","
                   :loaded_netrw 1
                   :loaded_netrwPlugin 1})]
  (tset vim.g k v))

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
                      [:fb (cmd :TelescopeB) (desc "search by buffer")]
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
                      [:frd
                       (cmd "Ddu -name=mrd mrd")
                       (desc "MRD (Most Recent Directories)")]
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
                      [:nt (cmd "Neorg journal today") (desc " Today")]
                      [:ny
                       (cmd "Neorg journal yesterday")
                       (desc " Yesterday")]
                      [:N (cmd :Neorg) (desc " Enter")]
                      [:nn (cmd :NeorgUID) (desc " UID")]
                      [:ngg (cmd :NeorgGit) (desc " Git")]
                      [:ngb (cmd :NeorgGitBranch) (desc " Git (branch)")]
                      [:fn
                       (cmd :NeorgFuzzySearch)
                       (desc "find Neorg linkable")]
                      ;; git
                      [:G (cmd :Neogit) (desc " client")]
                      [:gb (cmd :ToggleGitBlame) (desc " blame")]
                      ;; filter
                      [:tb
                       ; (lcmd "require('oil').toggle_float()")
                       (lcmd "require('lir.float').toggle()")
                       (desc "  explorer")]
                      [:tB
                       (lcmd "require('oil').open()")
                       (desc "  explorer")]
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
                      [:to (cmd :AerialToggle) (desc "toggle outline")]
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
  (each [m ks (pairs {:n [["¥" "\\"] [:<C-t> (cmd :OpenMenu)]]
                      :i [["¥" "\\"]]
                      :c [["¥" "\\"]]
                      :t [["¥" "\\"]]
                      :v [[:R (cmd :FlowRunSelected)] [:<C-t> (cmd :OpenMenu)]]})]
    (each [_ k (ipairs ks)]
      (vim.keymap.set m (. k 1) (. k 2) (or (. k 3) opts))))
  ;; term toggle keymaps
  (for [i 0 9]
    (vim.keymap.set [:n :t :i] (.. :<C- i ">")
                    (mk_toggle (+ 4 i) :terminal {:idx i}) opts)))

;; eager configs
((. (require :config-local) :setup) {:silent true})
