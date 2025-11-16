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
                   :equalalways false
                   ;; 不可視文字
                   :listchars "tab:> ,trail:-"
                   :list true})]
  (tset vim.opt k v))

(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})
      toggle (fn [id]
               #((. (require :toggler) :toggle) id))]
  (each [_ k (ipairs [[:<Leader>tz :<Cmd>NeoZoomToggle<CR> (desc " zoom")]
                      [:<Leader>tm
                       "<Cmd>lua require('codewindow').toggle_minimap()<CR>"
                       (desc " minimap")]
                      [:<Leader>to (toggle :aerial) (desc " outline")]
                      [:<Leader>U :<Cmd>Atone<CR> (desc " undotree")]
                      [:gx #((. (require :open) :open_cword)) (desc :open)]
                      [:<Leader>gb :<Cmd>BlameToggle<CR> (desc " blame")]
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

;; winbar
(macro cond [...]
  (let [clauses [...]]
    (assert (> (length clauses) 0) "cond: need at least one clause")
    (assert (= 0 (% (length clauses) 2))
            "cond: need even number of forms (test expr …)")
    (var i (length clauses))
    (var acc nil)
    (while (> i 0)
      (let [expr (. clauses i)
            test (. clauses (- i 1))]
        (if (= test :else)
            (set acc expr)
            (set acc `(if ,test ,expr ,acc))))
      (set i (- i 2)))
    acc))

(set _G._winbar #(let [buf (vim.api.nvim_get_current_buf)
                       name (vim.api.nvim_buf_get_name buf)
                       root (vim.fs.root buf [:.git :gradlew :package.json])
                       name (if root
                                (vim.fn.fnamemodify name (.. ":." root))
                                name)
                       base (vim.fn.fnamemodify name ":t")
                       dir (vim.fn.fnamemodify name ":h")
                       prefix (.. "%#Normal#%*" ; to avoid trim whitespaces
                                  (if vim.bo.modified " " "  "))]
                   (.. prefix
                       (cond ;
                             ;; no name ;;
                             (= name "") "[No Name]" ;
                             ;; root ;;
                             (= dir ".") base ;
                             ;; relative path ;;
                             true (.. base " - " dir)))))

(set vim.o.winbar "%r%{%v:lua._winbar()%}")
