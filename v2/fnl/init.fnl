; vim configs
(vim.loader.enable)

;; ネストNeovim防止
;; NVIM_AUTO_REMOTE=1 のときだけ、$NVIM 先へ引数ファイルを転送して即終了
;; 接続・転送に失敗した場合は通常起動にフォールバック
(when (and (= vim.env.NVIM_AUTO_REMOTE :1) vim.env.NVIM
           (> (length (vim.fn.argv)) 0))
  (var sent false)
  (let [(ok chan) (pcall vim.fn.sockconnect :pipe vim.env.NVIM {:rpc true})]
    (when (and ok (> chan 0))
      (each [_ f (ipairs (vim.fn.argv))]
        (let [(rok _) (pcall vim.rpcrequest chan :nvim_cmd
                             {:cmd :edit :args [(vim.fn.fnamemodify f ":p")]} {})]
          (when rok (set sent true))))
      (vim.fn.chanclose chan)))
  (when sent
    (vim.cmd :qa!)
    (lua :return)))

;; terminal子プロセス向けにEDITORを設定（軽量シェルラッパー）
(when (and vim.v.servername (not= vim.v.servername ""))
  (set vim.env.NVIM_EDITOR_ADDR vim.v.servername))

(fn update-editor-origin-window []
  (set vim.env.NVIM_EDITOR_WIN (tostring (vim.api.nvim_get_current_win))))

(update-editor-origin-window)

(vim.api.nvim_create_autocmd [:WinEnter :TabEnter]
                             {:callback update-editor-origin-window})

(when vim.g._editor_open_cmd
  (set vim.env.EDITOR vim.g._editor_open_cmd))

(when vim.g._editor_open_cmd_wait
  (set vim.env.GIT_EDITOR vim.g._editor_open_cmd_wait))

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
                             ; statuslineを起動時に非表示
                             :laststatus 0
                             :showtabline 0
                             :wrap false
                             :splitkeep :screen
                             ;; fold
                             :foldcolumn :1
                             :foldlevel 99
                             :foldlevelstart 99
                             :foldenable true
                             :switchbuf ""
                             :splitbelow true
                             :splitright true
                             :winborder :single}
                       :g {:mapleader " "
                           :maplocalleader ","
                           :loaded_netrw 1
                           :loaded_netrwPlugin 1
                           :no_plugin_maps true}})]
  (each [k v (pairs kvp)]
    (tset (. vim opt) k v)))

; register keymaps
(macro leader [...]
  `,(.. :<Leader> ...))

(macro local_leader [...]
  `,(.. :<LocalLeader> ...))

(macro cmd [c]
  `,(.. :<Cmd> c :<CR>))

(let [S (require :snacks)
      opts {:noremap true :silent true}
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
                          ; asterisk
                          ["*" "<Plug>(asterisk-z*)" {:silent true}]
                          ["#" "<Plug>(asterisk-z#)" {:silent true}]
                          [:g* "<Plug>(asterisk-gz*)" {:silent true}]
                          ["g#" "<Plug>(asterisk-gz#)" {:silent true}]
                          ; menu
                          [:<C-Space> (cmd :OpenMenu)]
                          ; create
                          [(leader :ct)
                           #(vim.ui.input {:prompt "Terminal: "}
                                          #(when (and $1 (not= $1 ""))
                                             (vim.cmd (.. "Pterm " $1))))
                           (desc "create terminal")]
                          ; close
                          [(leader :q)
                           S.bufdelete.delete
                           (desc "close buffer")]
                          [(leader :Q)
                           S.bufdelete.all
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
                          ; [(leader :fp)
                          ;  (cmd "Telescope find_files")
                          ;  (desc " files")]
                          [(leader :fp)
                           (cmd "Telescope find_files find_command=rg,--files,--hidden,-g,!.git")
                           (desc " files")]
                          [(leader :Ff)
                           (cmd "Telescope live_grep_args cwd=~/ghq")
                           (desc " livegrep (ghq)")]
                          ; [(leader :Fp)
                          ;  (cmd "Telescope find_files cwd=~/ghq")
                          ;  (desc " files (ghq)")]
                          [(leader :Fp)
                           (cmd "Telescope find_files cwd=~/ghq")
                           (desc " files (ghq)")]
                          [(leader :fP)
                           (cmd "Telescope ghq")
                           (desc " project files")]
                          [(leader :fb)
                           (cmd :TelescopeBuffer)
                           (desc " buffer")]
                          [(leader :fB)
                           (cmd :TelescopeBufferName)
                           (desc " buffer")]
                          [(leader :ft)
                           (cmd "Telescope pterm theme=cursor")
                           (desc " terminal")]
                          [(leader :fT)
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
                          [(leader :aa) (cmd :AvanteAsk)]
                          [(leader :at) (cmd :AvanteToggle)]
                          ;  Obsidian
                          [(leader :ot)
                           (cmd "Obsidian today")
                           (desc " journal today")]
                          [(leader :oy)
                           (cmd "Obsidian yesterday")
                           (desc " journal yesterday")]
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

(vim.cmd "colorscheme morimo")

((. (require :config-local) :setup) {:silent true})
