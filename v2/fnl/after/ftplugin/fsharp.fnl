(vim.api.nvim_create_autocmd [:BufEnter :InsertLeave]
                             {:callback #(vim.lsp.codelens.enable true
                                                                  {:bufnr 0})
                              :buffer 0})
