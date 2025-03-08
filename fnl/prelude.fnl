;; options
(vim.loader.enable)
(vim.cmd "language messages en_US.UTF-8")

(each [k v (pairs {:langmenu :none
                   :shortmess (.. vim.o.shortmess :sWcS)
                   :cmdheight 1
                   :showmode false
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

(let [O {:noremap true :silent true}
      D (fn [d] {:noremap true :silent true :desc d})
      C (fn [c] (.. :<cmd> c :<cr>))
      L (fn [c] (C (.. "lua " c)))
      T (fn [id]
          (fn []
            ((. (require :toggler) :toggle) id)))]
  ;; leader keymaps
  (each [_ K (ipairs [;; finder
                      [:ff
                       (C "Telescope live_grep_args")
                       (D "search by content")]
                      [:fF (C "Telescope ast_grep") (D "search by AST")]
                      [:fb (C :TelescopeB) (D "search by buffer")]
                      [:ft
                       (C "Telescope sonictemplate templates")
                       (D "search templates")]
                      [:fh (C :Legendary) (D "Search command palette")]
                      [:H
                       (L "require('harpoon').ui:toggle_quick_menu(require('harpoon'):list(),{border='none'})")
                       (D "Show registered file")]
                      [:ha
                       (L "require('harpoon'):list():add()")
                       (D "Register file")]
                      [:fp
                       (C "Ddu -name=files file_fd")
                       (D "search by file name")]
                      [:fP (C "Ddu -name=ghq ghq") (D "search repo (ghq)")]
                      [:fru
                       (C "Ddu -name=mru mru")
                       (D "MRU (Most Recently Used files)")]
                      [:frw
                       (C "Ddu -name=mrw mrw")
                       (D "MRW (Most Recently Written files)")]
                      [:frr
                       (C "Ddu -name=mrr mrr")
                       (D "MRR (Most Recent git Repositories)")]
                      [:frd
                       (C "Ddu -name=mrd mrd")
                       (D "MRD (Most Recent Directories)")]
                      ;; mark
                      [:mq (C :MarksQFListBuf) (D "marks in current buffer")]
                      [:mQ (C :MarksQFListGlobal) (D "marks in all buffer")]
                      ;; undo
                      [:U (C :UndotreeToggle (D "toggle undotree"))]
                      ;; neorg
                      [:nt (C "Neorg journal today") (D " Today")]
                      [:ny (C "Neorg journal yesterday") (D " Yesterday")]
                      [:N (C :Neorg) (D " Enter")]
                      [:nn (C :NeorgUID) (D " UID")]
                      [:ngg (C :NeorgGit) (D " Git")]
                      [:ngb (C :NeorgGitBranch) (D " Git (branch)")]
                      [:fn (C :NeorgFuzzySearch) (D "find Neorg linkable")]
                      ;; git
                      ; [:G (C :Neogit) (D " client")]
                      [:G (T :gitu) (D " client")]
                      [:gb (T :blame) (D " blame")]
                      ;; filter
                      [:tb
                       ; (lcmd "require('oil').toggle_float()")
                       (L "require('lir.float').toggle()")
                       (D "  explorer")]
                      [:tB (L "require('oil').open()") (D "  explorer")]
                      ;; buffer
                      [:q (C :BufDel) (D "close buffer")]
                      [:Q (C :BufDelAll) (D "close all buffers")]
                      ;; tab
                      [:A (C :tabclose)]
                      ;; toggle
                      [:ts (C "Screenkey toggle") (D "toggle screenkey")]
                      [:tc (C :ColorizerToggle) (D "toggle colorizer")]
                      [:tt (C :NoNeckPain) (D "toggle no neck pain")]
                      [:tm
                       (L "require('codewindow').toggle_minimap()")
                       (D "toggle minimap")]
                      [:to (C :AerialToggle) (D "toggle outline")]
                      [:tj
                       (C "lua require('treesj').toggle({ split = { recursive = false }})")
                       (D "toggle split/join")]
                      [:tJ
                       (C "lua require('treesj').toggle({ split = { recursive = true }})")
                       (D "toggle recursive split/join")]
                      [:tq (T :qf) (D "toggle quickfix")]
                      [:td
                       (T :trouble-doc)
                       (D "toggle diagnostics (document)")]
                      [:tD
                       (T :trouble-ws)
                       (D "toggle diagnostics (workspace)")]
                      [:tR
                       (L "require('spectre').toggle()")
                       (D "toggle spectre")]
                      ;; copilot chat
                      [:ta (C :TCopilotChatToggle)]
                      ;; AI
                      [:aa (C :AvanteAsk) (D "Avante Ask")]
                      [:at (C :TAvanteToggle) (D "Avante Toggle")]])]
    (vim.keymap.set :n (.. :<Leader> (. K 1)) (. K 2) (or (. K 3) O)))
  (each [m ks (pairs {:n [["¥" "\\"] [:<C-t> (C :OpenMenu)]]
                      :i [["¥" "\\"]]
                      :c [["¥" "\\"]]
                      :t [["¥" "\\"]]
                      :v [[:R (C :FlowRunSelected)] [:<C-t> (C :OpenMenu)]]})]
    (each [_ k (ipairs ks)]
      (vim.keymap.set m (. k 1) (. k 2) (or (. k 3) O))))
  ;; term toggle keymaps
  (for [i 0 9]
    (vim.keymap.set [:n :t :i] (.. :<C- i ">") (T (.. :term i)) O)))

;; eager configs
((. (require :config-local) :setup) {:silent true})
