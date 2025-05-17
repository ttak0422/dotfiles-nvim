(local crates (require :crates))

(local lsp {:enabled true :actions true :completion false :hover true})
(local null_ls {:enabled true :name :crates.nvim})

(crates.setup {: lsp : null_ls})
