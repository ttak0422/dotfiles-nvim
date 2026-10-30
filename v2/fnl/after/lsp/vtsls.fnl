{:single_file_support false
 :workspace_required true
 :root_markers [:tsconfig.json :package.json :jsconfig.json :.node_project]
 ;; Keep other suggestions; only hide the CommonJS-to-ES-module suggestion.
 ;; Resolve the global handler at notification time to preserve later wrappers.
 :handlers {:textDocument/publishDiagnostics
            (fn [err result ctx config]
              (local filtered
                (if (and (not err) result result.diagnostics)
                    (vim.tbl_extend :force {} result
                                    {:diagnostics (vim.tbl_filter
                                                    (fn [d] (and (not= d.code 80001)
                                                                 (not= d.code "80001")))
                                                    result.diagnostics)})
                    result))
              ((. vim.lsp.handlers :textDocument/publishDiagnostics)
               err filtered ctx config))}
 :settings {:separate_diagnostic_server true
            :publish_diagnostic_on :insert_leave
            :typescript {:suggest {:completeFunctionCalls true}
                         :preferences {:importModuleSpecifier :relative}}}
 :flags {:debounce_text_changes 1000}
 :vtsls {:experimental {:completion {:enableServerSideFuzzyMatch true}}}}
