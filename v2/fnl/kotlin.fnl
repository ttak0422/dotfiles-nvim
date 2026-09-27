(set vim.env.KOTLIN_LSP_DIR args.kotlin_lsp_dir)

(local kotlin (require :kotlin))
(local opts {:java_files false :inlay_hints {:enabled true}})

(kotlin.setup opts)

;; Bundler loads this from after/ftplugin, during the first FileType event.
;; The plugin's newly registered FileType autocmd misses that buffer.
(when (= vim.bo.filetype :kotlin)
  (kotlin.setup_kotlin_lsp opts))
