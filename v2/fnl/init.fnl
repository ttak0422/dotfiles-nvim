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
                       :env {:VISUAL "nvr --remote-silent"
                             :EDITOR "nvr --remote-silent"
                             :GIT_EDITOR "nvr --remote-silent"}
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
(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})
      cmd (fn [c] (.. :<cmd> c :<cr>))
      git (fn []
            (vim.cmd :enew)
            (let [bufnr (vim.api.nvim_get_current_buf)
                  on_exit (fn []
                            (fn []
                              (if (vim.api.nvim_buf_is_valid bufnr)
                                  (vim.api.nvim_buf_delete bufnr {:force true}))))]
              (vim.fn.termopen :gitu {: on_exit})
              (vim.cmd :startinsert)
              (tset (. vim.bo bufnr) :bufhidden :wipe)
              (tset (. vim.bo bufnr) :swapfile false)
              (tset (. vim.bo bufnr) :buflisted false) ; (vim.api.nvim_create_autocmd :BufLeave ;                              {:buffer bufnr ;                               :once true ;                               :callback on_exit})
              (vim.api.nvim_create_autocmd :TermClose
                                           {:buffer bufnr
                                            :once true
                                            :callback (fn []
                                                        (vim.api.nvim_feedkeys :i
                                                                               :n
                                                                               false))})))
      toggle (fn [id]
               (fn []
                 ((. (require :toggler) :toggle) id)))]
  (each [m ks (pairs {:n [["¥" "\\"]
                          [";" ":"]
                          ; toggle
                          [:tq (toggle :qf) (desc " quickfix")]
                          [:tb
                           (cmd "lua require('lir.float').toggle()")
                           (desc " explorer")]
                          [:tB
                           (cmd "lua require('oil').open()")
                           (desc " explorer")]
                          ; git
                          [:<Leader>G git (desc " client")]]
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
