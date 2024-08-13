(let [null_ls (require :null-ls)
      diagnostics null_ls.builtins.diagnostics
      formatting null_ls.builtins.formatting
      utils (require :null-ls.utils)
      is_active_lsp (fn [lsp_name]
                      (let [bufnr (vim.api.nvim_get_current_buf)
                            clients (vim.lsp.get_clients {: bufnr})]
                        (accumulate [acc false _ client (ipairs clients)]
                          (or acc (= lsp_name client.name)))))
      sources [;; code_actions
               ;; --- diagnostics --- ;;
               ;; go
               diagnostics.staticcheck
               ;; --- formatting --- ;;
               ;; lua
               formatting.stylua
               ;; sh
               formatting.shfmt
               ;; java
               formatting.google_java_format
               ;; yapf
               formatting.yapf
               ;; js/ts (node)
               (formatting.prettier.with {:prefer_local :node_modules/.bin
                                          :runtime_condition (fn [...]
                                                               (not (is_active_lsp :denols)))})
               ;; html
               formatting.tidy
               ;; go
               formatting.gofumpt
               ;; fennel
               formatting.fnlfmt
               ;; nix
               formatting.nixfmt]]
  (null_ls.setup {:border :none
                  :cmd [:nvim]
                  :debounce 250
                  :debug false
                  :default_timeout 10000
                  :diagnostic_config {}
                  :diagnostics_format "#{m} (#{s})"
                  :fallback_severity vim.diagnostic.severity.ERROR
                  :log_level :warn
                  :notify_format "[null-ls] %s"
                  :on_attach nil
                  :on_init nil
                  :on_exit nil
                  :root_dir (utils.root_pattern [:.null-ls-root :.git])
                  :root_dir_async nil
                  :should_attach nil
                  :temp_dir nil
                  :update_in_insert false
                  : sources}))
