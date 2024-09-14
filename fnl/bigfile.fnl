((. (require :bigfile) :setup) {:filesize 2
                                :pattern ["*"]
                                :features [:lsp
                                           :treesitter
                                           :syntax
                                           :matchparen
                                           :vimopts
                                           :filetype]})
