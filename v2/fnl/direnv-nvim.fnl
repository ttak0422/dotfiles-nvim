(when (= vim.g.direnv_nvim_original_path nil)
  (set vim.g.direnv_nvim_original_path (or vim.env.PATH "")))

(fn split-path [path]
  (if (and path (not= path ""))
      (vim.split path ":" {:plain true :trimempty true})
      []))

(fn merge-path [current original]
  (let [items (split-path current)
        seen {}]
    (each [_ item (ipairs items)]
      (tset seen item true))
    (each [_ item (ipairs (split-path original))]
      (when (not (. seen item))
        (table.insert items item)
        (tset seen item true)))
    (table.concat items ":")))

(vim.api.nvim_create_autocmd :User
                             {:pattern :DirenvLoaded
                              :callback #(set vim.env.PATH
                                              (merge-path vim.env.PATH
                                                          vim.g.direnv_nvim_original_path))})

((. (require :direnv) :setup) {:autoload_direnv true
                               :statusline {:enabled false}
                               :keybindings {}
                               :notifications {:silent_autoload true}})
