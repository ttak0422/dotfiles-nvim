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
      ; splitしなかったときに閉じないようにしたい
      git (fn []
            (if (= (length (vim.api.nvim_list_wins)) 1)
                (let [w (vim.api.nvim_win_get_width 0)
                      h (* (vim.api.nvim_win_get_height 0) 2.1)]
                  (if (> h w) (vim.cmd.split) (vim.cmd.vsplit))))
            (vim.cmd.enew)
            (let [bufnr (vim.api.nvim_get_current_buf)
                  on_exit (fn []
                            (if (not= (length (vim.api.nvim_list_wins)) 1)
                                (let [buf (vim.fn.bufnr "#")]
                                  (if (and (not= buf -1)
                                           (vim.api.nvim_buf_is_valid buf))
                                      (vim.api.nvim_win_set_buf (vim.api.nvim_get_current_win)
                                                                buf)))
                                (if (vim.api.nvim_buf_is_valid bufnr)
                                    (vim.api.nvim_buf_delete bufnr
                                                             {:force true}))))]
              (vim.fn.termopen :gitu {: on_exit})
              (vim.cmd.startinsert)
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
                                            :callback (fn [])})))
      toggle (fn [id]
               #((. (require :toggler) :toggle) id))]
  (each [m ks (pairs {:n [["¥" "\\"]
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
                          [(leader :td)
                           (toggle :trouble-doc)
                           (desc " diagnostics (doc)")]
                          [(leader :tD)
                           (toggle :trouble-ws)
                           (desc " diagnostics (ws)")]
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
                          [(leader :fp)
                           (cmd "Telescope find_files hidden=true")
                           (desc " files")]
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
                      :v [["¥" "\\"]]})]
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
