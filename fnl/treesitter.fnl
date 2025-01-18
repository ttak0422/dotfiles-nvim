(local parser_install_dir args.parser)

(vim.opt.runtimepath:prepend parser_install_dir)

; Folding
(set vim.wo.foldmethod :expr)
(set vim.wo.foldexpr "v:lua.vim.treesitter.foldexpr()")

(let [config (require :nvim-treesitter.configs)
      highlight {:enable true
                 :additional_vim_regex_highlighting false
                 :disable (fn [_lang buf]
                            (let [max_filesize (* 100 1024)
                                  (ok stats) (pcall vim.loop.fs_stat
                                                    (vim.api.nvim_buf_get_name buf))]
                              (and ok stats (> stats.size max_filesize))))}
      indent {:enable true}]
  (config.setup {:sync_install false
                 :auto_install false
                 :ignore_install []
                 : parser_install_dir
                 : highlight
                 : indent}))
