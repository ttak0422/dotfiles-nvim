(vim.api.nvim_create_autocmd [:BufEnter :InsertLeave]
                             {
                              :callback vim.lsp.codelens.refresh
                              :buffer 0})
