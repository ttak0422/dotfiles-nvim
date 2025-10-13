(let [otter (require :otter)
      lsp {:diagnostic_update_events [:BufWritePost]
           :root_dir (fn [_ bufnr]
                       (or (vim.fs.root (or bufnr 0)
                                        [:.git :_quarto.yml :package.json])
                           (vim.fn.getcwd 0)))}
      buffers {:write_to_disk true
               :preambles {}
               :postambles {}
               :ignore_pattern {:python "^(%s*[%%!].*)"}}]
  (otter.setup {: lsp
                : buffers
                :strip_wrapping_quote_characters ["'" "\"" "`"]
                :handle_leading_whitespace true
                :extensions {}
                :debug false
                :verbose {:no_code_found false}}))
