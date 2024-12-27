((. (require :crates) :setup) {:lsp {:enabled true
                                     :actions true
                                     :completion false
                                     :hover true}}
                              :null_ls {:enabled true :name :crates.nvim})
