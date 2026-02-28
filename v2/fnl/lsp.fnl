;; global configs
(vim.lsp.set_log_level vim.log.levels.ERROR)

;; per-client diagnostic severity filter (severity value: ERROR=1 WARN=2 INFO=3 HINT=4)
;; lower value = higher severity; diagnostics with severity > threshold are filtered out
(local diagnostic-min-severity {:kotlin_ls vim.diagnostic.severity.INFO})

(doto vim.lsp.handlers
  (tset :textDocument/hover (vim.lsp.with vim.lsp.handlers.hover
                              {:border :single}))
  (tset :textDocument/publishDiagnostics
        (let [handler (vim.lsp.with vim.lsp.diagnostic.on_publish_diagnostics
                        {:update_in_insert false})]
          (fn [err result ctx config]
            (let [client (vim.lsp.get_client_by_id ctx.client_id)
                  min-sev (when client
                            (. diagnostic-min-severity client.name))]
              (when (and min-sev result result.diagnostics)
                (set result.diagnostics
                     (vim.tbl_filter (fn [d] (<= d.severity min-sev))
                                     result.diagnostics)))
              (handler err result ctx config))))))

(vim.diagnostic.config {:severity_sort true
                        :virtual_text false
                        :update_in_insert false
                        :signs {:text {vim.diagnostic.severity.ERROR ""
                                       vim.diagnostic.severity.WARN ""
                                       vim.diagnostic.severity.INFO ""
                                       vim.diagnostic.severity.HINT ""}
                                :numhl {vim.diagnostic.severity.ERROR ""
                                        vim.diagnostic.severity.WARN ""
                                        vim.diagnostic.severity.INFO ""
                                        vim.diagnostic.severity.HINT ""}}})

;; keymaps
(vim.api.nvim_create_autocmd :LspAttach
                             {:desc "register lsp keymaps"
                              :callback (fn [ctx]
                                          ((dofile args.attach_path) {:buf ctx.buf
                                                                      :client (vim.lsp.get_client_by_id ctx.data.client_id)}))})

;; setup
(vim.lsp.enable [:bashls
                 ; :csharp_ls
                 :cssls
                 :dartls
                 :denols
                 :dhall_lsp_server
                 :fennel_ls
                 :gopls
                 :harper_ls
                 :html
                 :jsonls
                 :lua_ls
                 :marksman
                 :nil_ls
                 :pyright
                 :rubocop
                 :ruff
                 :solargraph
                 :taplo
                 :terraformls
                 :vtsls
                 :yamlls])
