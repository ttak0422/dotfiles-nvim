(local crates (require :crates))

(local lsp {:enabled true :actions true :completion false :hover true})

;; Code actions and hover use crates.nvim's in-process LSP.
(crates.setup {: lsp})
