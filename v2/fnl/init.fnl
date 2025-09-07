; vim configs
(vim.loader.enable)
(vim.cmd "language messages en_US.UTF-8")

;; WIP
(pcall dofile (vim.fn.expand :$HOME/config.lua))

(each [opt kvp (pairs {:opt {:langmenu :none
                             :timeoutlen 1000
                             :shortmess (.. vim.o.shortmess :sWcS)
                             :cmdheight 0
                             :showmode false
                             :number false
                             ;; signcolumnを起動時に表示
                             :signcolumn :yes
                             :showtabline 0
                             ; statuslineを起動時に非表示
                             :laststatus 0
                             :showtabline 0
                             :wrap false
                             :splitkeep :screen
                             ;; fold
                             :foldcolumn "auto:1"
                             :foldlevel 99
                             :foldlevelstart 99
                             :foldenable true
                             :switchbuf ""}
                       ; :o {}
                       :env {:VISUAL "nvr --remote-wait-silent"
                             :EDITOR "nvr --remote-wait-silent"
                             :GIT_EDITOR "nvr --remote-wait-silent"}
                       :g {:mapleader " "
                           :maplocalleader ","
                           :loaded_netrw 1
                           :loaded_netrwPlugin 1}})]
  (each [k v (pairs kvp)]
    (tset (. vim opt) k v)))

; register keymaps
(macro leader [...]
  `,(.. :<Leader> ...))

(macro local_leader [...]
  `,(.. :<LocalLeader> ...))

(macro cmd [c]
  `,(.. :<Cmd> c :<CR>))

(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})
      lua_ (fn [mod f opt]
             #(if (= opt nil)
                  ((. (require mod) f))
                  ((. (require mod) f) opt)))
      toggle (fn [id]
               #((. (require :toggler) :toggle) id))]
  (each [m ks (pairs {:n [[:j :gj]
                          [:k :gk]
                          ["¥" "\\"]
                          [:<esc><esc> (cmd :nohl)]
                          ; menu
                          [:<C-Space> (cmd :OpenMenu)]
                          ; close
                          [(leader :q) (cmd :BufDel) (desc "close buffer")]
                          [(leader :Q)
                           (cmd :BufDelAll)
                           (desc "close all buffers")]
                          [(leader :A) (cmd :tabclose)]
                          ;  Toggle
                          [(leader :tq) (toggle :qf) (desc " quickfix")]
                          [(leader :tb)
                           #(if (= vim.bo.buftype "")
                                ((. (require :lir.float) :toggle))
                                (vim.notify "Not a file buffer" :warn))
                           (desc " explorer")]
                          [(leader :tB)
                           (lua_ :oil :open)
                           (desc " explorer")]
                          [(leader :td)
                           (toggle :trouble-doc)
                           (desc " diagnostics (doc)")]
                          [(leader :tD)
                           (toggle :trouble-ws)
                           (desc " diagnostics (ws)")]
                          [(leader :tR)
                           (lua_ :spectre :toggle)
                           (desc " replace")]
                          ; 󰢷 Harpoon
                          [(leader :H)
                           (toggle :harpoon)
                           (desc "󰢷 show items")]
                          [(leader :ha)
                           (cmd "lua require('harpoon'):list():add()")
                           (desc "󰢷 register item")]
                          ;  Telescope
                          [(leader :ff)
                           (cmd "Telescope live_grep_args")
                           (desc " livegrep")]
                          [(leader :fp)
                           (cmd "Telescope find_files")
                           (desc " files")]
                          [(leader :Ff)
                           (cmd "Telescope live_grep_args cwd=~/ghq")
                           (desc " livegrep (ghq)")]
                          [(leader :Fp)
                           (cmd "Telescope find_files cwd=~/ghq")
                           (desc " files (ghq)")]
                          [(leader :fP)
                           (cmd "Telescope projects")
                           (desc " project files")]
                          [(leader :fb)
                           (cmd :TelescopeBuffer)
                           (desc " buffer")]
                          [(leader :fB)
                           (cmd :TelescopeBufferName)
                           (desc " buffer")]
                          [(leader :ft)
                           (cmd "Telescope sonictemplate templates")
                           (desc " template")]
                          [(leader :fru)
                           #(vim.cmd (.. "Telescope mr mru cwd="
                                         (vim.fn.fnameescape (vim.fn.getcwd))))
                           (desc " MRU")]
                          [(leader :frr)
                           #(vim.cmd (.. "Telescope mr mrr cwd="
                                         (vim.fn.fnameescape (vim.fn.getcwd))))
                           (desc " MRR")]
                          [(leader :frw)
                           #(vim.cmd (.. "Telescope mr mrw cwd="
                                         (vim.fn.fnameescape (vim.fn.getcwd))))
                           (desc " MRW")]
                          [(leader :Fru)
                           (cmd "Telescope mr mru")
                           (desc " MRU")]
                          [(leader :Frr)
                           (cmd "Telescope mr mrr")
                           (desc " MRR")]
                          [(leader :Frw)
                           (cmd "Telescope mr mrw")
                           (desc " MRW")]
                          [(leader :fn)
                           (cmd :NeorgFuzzySearch)
                           (desc " fuzzy search")]
                          [(leader :fN)
                           (cmd :NeorgFindFile)
                           (desc " find file")]
                          ;  Git
                          [(leader :G) (cmd :Gitu) (desc " client")]
                          ;[(leader :gb) (toggle :blame) (desc " blame")]
                          [(leader :go) (cmd :TracePR) (desc " open PR")]
                          ;  Neorg
                          [(leader :N) (cmd :Neorg) (desc " enter")]
                          [(leader :ny)
                           (cmd "Neorg journal yesterday")
                           (desc " yesterday")]
                          [(leader :nt)
                           (cmd "Neorg journal today")
                           (desc " today")]
                          [(leader :nT)
                           (cmd "Neorg journal tomorrow")
                           (desc " tomorrow")]
                          [(leader :nn)
                           (cmd :NeorgScratch)
                           (desc " scratch")]
                          [(leader :ngg) (cmd :NeorgGit) (desc " Git")]
                          [(leader :ngb)
                           (cmd :NeorgGitBranch)
                           (desc " Git (branch)")]
                          ; [:<C-c> (cmd :AvanteFocus) (desc "Avante Chat")]
                          ;  Obsidian
                          [(leader :O) (cmd :Obsidian) (desc " enter")]
                          [(leader :ot)
                           (cmd "Obsidian today")
                           (desc " journal today")]
                          [(leader :oo)
                           (cmd :ObsidianScratch)
                           (desc " new note")]
                          [(leader :ogg) (cmd :ObsidianGit) (desc " Git")]
                          [(leader :ogb)
                           (cmd :ObsidianGitBranch)
                           (desc " Git branch")]
                          [(leader :on)
                           (cmd "Obsidian new")
                           (desc " new note")]
                          [(leader :fo)
                           (cmd "Obsidian search")
                           (desc " fuzzy search")]]
                      :i [["¥" "\\"]]
                      :c [["¥" "\\"]]
                      :t [["¥" "\\"] [:<S-Space> :<Space>]]
                      :v [["¥" "\\"]
                          ; menu
                          [:<C-t> (cmd :OpenMenu)]]})]
    (each [_ k (ipairs ks)]
      (vim.keymap.set m (. k 1) (. k 2) (or (. k 3) opts))))
  (for [i 0 9]
    (vim.keymap.set [:n :t :i] (.. :<C- i ">") (toggle (.. :term i)) opts)))

; startup plugin configs
(vim.cmd "colorscheme morimo")
(each [_ p (ipairs [:nvim-notify
                    :treesitter
                    :gitsigns
                    :lir
                    :dap
                    :git-conflict
                    :lir])]
  ((. (require :morimo) :load) p))

((. (require :config-local) :setup) {:silent true})
