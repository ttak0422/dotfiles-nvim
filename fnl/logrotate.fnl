((. (require :logrotate) :setup) {:targets [(.. (vim.fn.stdpath :state)
                                                :/lsp.log)]
                                  :interval :daily})
