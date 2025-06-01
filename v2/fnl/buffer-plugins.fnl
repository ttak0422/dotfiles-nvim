(local cachedir (vim.fn.stdpath :cache))
(each [k v (pairs {:updatetime 100
                   :hidden true
                   :autoread true
                   :startofline false
                   ;; undofile
                   :undofile true
                   :undodir (.. cachedir :/undo)
                   ;; swapfile
                   :swapfile true
                   :directory (.. cachedir :/swap)
                   ;; backup
                   :backup true
                   :backupcopy :yes
                   :backupdir (.. cachedir :/backup)
                   ;; ウィンドウ分割時にサイズを均等にしようとしない
                   :equalalways false})]
  (tset vim.opt k v))

(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})
      toggle (fn [id]
               #((. (require :toggler) :toggle) id))]
  (each [_ k (ipairs [[:<Leader>U
                       :<Cmd>UndotreeToggle<CR>
                       (desc " undotree")]
                      [:gx #((. (require :open) :open_cword)) (desc :open)]
                      ; dap
                      [:<LocalLeader>db
                       #((-> (require :dap)
                             (. :toggle_breakpoint)))
                       (desc " breakpoint")]
                      [:<LocalLeader>dr
                       #((-> (require :dap)
                             (. :repl)
                             (. :toggle)))
                       (desc " repl")]
                      [:<LocalLeader>dl
                       #((-> (require :dap)
                             (. :run_last)))
                       (desc " run last")]
                      [:<LocalLeader>dd (toggle :dapui) (desc " run last")]])]
    (vim.keymap.set :n (. k 1) (. k 2) (or (. k 3) opts))))
