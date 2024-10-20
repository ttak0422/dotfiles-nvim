((. (require :crates) :setup) {:lsp {:enabled true
                                     :on_attach (dofile args.on_attach_path)
                                     :actions true
                                     :completion false
                                     :hover true}}
                              :null_ls {:enabled true :name :crates.nvim})
