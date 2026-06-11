(local project (require :project_nvim))

(project.setup {:manual_mode false
                :scope_chdir :tab
                :detection_methods [:pattern]
                :patterns [:.git]})

;; project.nvim は .git の「ファイル(submodule)」と「ディレクトリ」を区別せず、
;; submodule 内に入ると submodule ルートへ chdir してしまう。
;; submodule なら親リポジトリ(superproject)のルートへ戻して、移動しないようにする。
(local augroup (vim.api.nvim_create_augroup :ProjectSubmoduleGuard {:clear true}))

(var adjusting false)

(fn superproject-root [dir]
  (let [out (vim.fn.system [:git :-C dir :rev-parse :--show-superproject-working-tree])
        root (vim.trim out)]
    (when (and (= vim.v.shell_error 0) (not= root ""))
      root)))

(vim.api.nvim_create_autocmd :DirChanged
                             {:group augroup
                              :pattern [:global :tabpage]
                              :callback (fn []
                                          (when (not adjusting)
                                            (let [root (superproject-root (vim.fn.getcwd))]
                                              (when root
                                                (set adjusting true)
                                                (pcall vim.cmd.tcd
                                                       (vim.fn.fnameescape root))
                                                (set adjusting false)))))})
