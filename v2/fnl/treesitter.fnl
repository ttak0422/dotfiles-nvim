;; HACK
(local parser_install_dir args.parser)

(vim.opt.runtimepath:prepend parser_install_dir)

(let [config (require :nvim-treesitter.configs)
      parser (require :nvim-treesitter.parsers)
      parser_configs (parser.get_parser_configs)
      highlight {:enable true
                 :additional_vim_regex_highlighting false
                 :disable (fn [_lang buf]
                            (let [max_filesize (* 100 1024)
                                  (ok stats) (pcall vim.loop.fs_stat
                                                    (vim.api.nvim_buf_get_name buf))]
                              (and ok stats (> stats.size max_filesize))))}
      indent {:enable true}]
  ;; HACK
  (tset parser_configs :dap_repl {:install_info {}})
  (tset parser_configs :norg_meta {:install_info {}})
  (config.setup {:sync_install false
                 :auto_install false
                 :ignore_install []
                 : parser_install_dir
                 : highlight
                 : indent}))
