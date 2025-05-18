; vim configs
(vim.loader.enable)
(vim.cmd "language messages en_US.UTF-8")

(each [opt kvp (pairs {:opt {:langmenu :none
                             :shortmess (.. vim.o.shortmess :sWcS)
                             :cmdheight 0
                             :showmode false
                             :number true
                             ;; signcolumnを起動時に表示
                             :signcolumn :yes
                             ;; tablineを起動時に非表示
                             :showtabline 0
                             ; statuslineを起動時に非表示
                             :laststatus 0
                             :foldcolumn :1
                             :splitkeep :screen}
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

(vim.api.nvim_create_autocmd :FileType
                             {:pattern "*"
                              :callback (fn []
                                          (vim.opt_local.formatoptions:remove :r)
                                          (vim.opt_local.formatoptions:remove :o))})

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
      git2 (fn []
             (let [dir (vim.fn.expand "%:p:h")
                       popup_id (-> (require :detour) (. :Detour))
                       ]
               (if (popup_id)
                   (do
                     (vim.cmd.lcd dir)
                     (vim.cmd.terminal :gitu)
                     (set vim.bo.bufhidden :delete)
                     ;(tset (. vim.wo popup_id) :signcolumn :no )
                     (vim.keymap.set :t :<Esc> :<Esc> { :buffer true })
                     (vim.cmd.startinsert)
                     (vim.api.nvim_create_autocmd [:TermClose] {
                                                  :buffer (vim.api.nvim_get_current_buf)
                                                  :callback #(vim.api.nvim_feedkeys :i :n false)
                                                  })


                     )

                   )
               )
;local current_dir = vim.fn.expand("%:p:h")
;local popup_id = require("detour").Detour() -- open a detour popup
;if not popup_id then
;return
;end
;
;-- Set this window's current working directory to current file's directory.
;-- tig finds a git repo based on the current working directory.
;vim.cmd.lcd(current_dir)
;
;vim.cmd.terminal("tig") -- open a terminal buffer running tig
;vim.bo.bufhidden = "delete" -- close the terminal when window closes
;vim.wo[popup_id].signcolumn = "no" -- In Neovim 0.10, the signcolumn can push the TUI a bit out of window
;
;-- It's common for people to have `<Esc>` mapped to `<C-\><C-n>` for terminals.
;-- This can get in the way when interacting with TUIs.
;-- This maps the escape key back to itself (for this buffer) to fix this problem.
;vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = true })
;
;vim.cmd.startinsert() -- go to insert mode
;
;vim.api.nvim_create_autocmd({ "TermClose" }, {
;buffer = vim.api.nvim_get_current_buf(),
;callback = function()
;-- This automated keypress skips for you the "[Process exited 0]" message
;-- that the embedded terminal shows.
;vim.api.nvim_feedkeys("i", "n", false)
;end,
;})
             )
      git (fn []
            (vim.cmd :enew)
            (let [bufnr (vim.api.nvim_get_current_buf)
                  on_exit ##(if (vim.api.nvim_buf_is_valid bufnr)
                                (vim.api.nvim_buf_delete bufnr {:force true}))]
              (vim.fn.termopen :gitu {: on_exit})
              (vim.cmd :startinsert)
              (tset (. vim.bo bufnr) :bufhidden :wipe)
              (tset (. vim.bo bufnr) :swapfile false)
              (tset (. vim.bo bufnr) :buflisted false)
              (vim.api.nvim_create_autocmd :BufLeave
                                           {:buffer bufnr
                                            :once true
                                            :callback on_exit})
              (vim.api.nvim_create_autocmd :TermClose
                                           {:buffer bufnr
                                            :once true
                                            :callback #(vim.api.nvim_feedkeys :i
                                                                              :n
                                                                              false)})))
      toggle (fn [id]
               #((. (require :toggler) :toggle) id))]
  (each [m ks (pairs {:n [["¥" "\\"]
                          [";" ":"]
                          [:j :gj]
                          [:k :gk]
                          [:<esc><esc> (cmd :nohl)]
                          ; close
                          [(leader :q) (cmd :BufDel) (desc "close buffer")]
                          [(leader :Q)
                           (cmd :BufDelAll)
                           (desc "close all buffers")]
                          [(leader :A) (cmd :tabclose)]
                          ;  Toggle
                          [(leader :tq) (toggle :qf) (desc " quickfix")]
                          [(leader :tb)
                           (lua_ :lir.float :toggle)
                           (desc " explorer")]
                          [(leader :tB)
                           (lua_ :oil :open)
                           (desc " explorer")]
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
                          [(leader :fF)
                           (cmd "Telescope ast_grep")
                           (desc " AST")]
                          [(leader :fb)
                           (cmd :TelescopeBuffer)
                           (desc " buffer")]
                          [(leader :ft)
                           (cmd "Telescope sonictemplate templates")
                           (desc " template")]
                          ;  Git
                          [(leader :G) git (desc " client")]
                          [(leader :gb) (toggle :blame) (desc " blame")]
                          [(leader :go) (cmd :TracePR) (desc " open PR")]
                          ;
                          ]
                      :i [["¥" "\\"]]
                      :c [["¥" "\\"]]
                      :t [["¥" "\\"] [:<S-Space> :<Space>]]
                      :v [["¥" "\\"]
                          [";" ":"]
                          ]})]
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
