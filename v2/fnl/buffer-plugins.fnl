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
      desc (fn [d] {:noremap true :silent true :desc d})]
  (each [_ k (ipairs [[:<Leader>U
                       :<Cmd>UndotreeToggle<CR>
                       (desc " undotree")]
                      [:gx #((. (require :open) :open_cword)) (desc :open)]])]
    (vim.keymap.set :n (. k 1) (. k 2) (or (. k 3) opts))))
