;; global configs
(vim.lsp.set_log_level vim.log.levels.ERROR)

(doto vim.lsp.handlers
  (tset :textDocument/hover (vim.lsp.with vim.lsp.handlers.hover
                              {:border :none}))
  (tset :textDocument/publishDiagnostics
        (vim.lsp.with vim.lsp.diagnostic.on_publish_diagnostics
          {:update_in_insert false})))

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
                 :typos_lsp
                 :vtsls
                 :yamlls])
