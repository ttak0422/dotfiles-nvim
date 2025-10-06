;; TODO: LSPの再起動など
((. (require :direnv) :setup) {:autoload_direnv true
                               :statusline {:enabled false}
                               :keybindings {;; :allow  "<Leader>da"
                                             ;; :deny  "<Leader>dd"
                                             ;; :reload  "<Leader>dr"
                                             ;; :edit  "<Leader>de"
                                             }
                               :notifications {:level vim.log.levels.INFO
                                               :silent_autoload false}})
