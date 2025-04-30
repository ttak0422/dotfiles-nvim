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
(let [cmd (fn [c] (.. :<cmd> c :<cr>))
      noice_lsp (require :noice.lsp)
      callback (fn [ctx]
                 (let [bufnr ctx.buf
                       desc (fn [d]
                              {:noremap true
                               :silent true
                               :buffer bufnr
                               :desc d})]
                   (each [_ k (ipairs [; builtin
                                       [:gd
                                        vim.lsp.buf.definition
                                        "go to definition"]
                                       [:gi
                                        vim.lsp.buf.implementation
                                        "go to implementation"]
                                       [:gr
                                        vim.lsp.buf.references
                                        "go to references"]
                                       [:<Leader>K
                                        vim.lsp.buf.signature_help
                                        "show signature"]
                                       [:<Leader>D
                                        vim.lsp.buf.type_definition
                                        "show type"]
                                       [:<Leader>ca
                                        vim.lsp.buf.code_action
                                        "code action"]
                                       ; plugin
                                       [; https://github.com/neovim/nvim-lspconfig/issues/3036
                                        :K
                                        noice_lsp.hover
                                        "show doc"]
                                       [:gD
                                        (cmd "Glance definitions")
                                        "go to definition"]
                                       [:gI
                                        (cmd "Glance implementations")
                                        "go to impl"]
                                       [:gR
                                        (cmd "Glance references")
                                        "go to references"]
                                       [:<leader>cc
                                        (cmd "Neogen class")
                                        "class comment"]
                                       [:<leader>cf
                                        (cmd "Neogen func")
                                        "fn comment"]
                                       [:<leader>rn ":IncRename " :rename]])]
                     (vim.keymap.set :n (. k 1) (. k 2)
                                     (desc (.. " " (. k 3)))))
                   (vim.keymap.set :n :<leader>rN
                                   (fn []
                                     (.. ":IncRename " (vim.fn.expand :<cword>)))
                                   {:noremap true
                                    :silent true
                                    :expr true
                                    :buffer bufnr
                                    :desc :rename})
                   (vim.keymap.set :n :<leader>cF vim.lsp.buf.format
                                   (desc " format"))
                   (vim.keymap.set [:n :v] :<C-CR> vim.lsp.buf.format
                                   (desc " format"))))]
  (vim.api.nvim_create_autocmd :LspAttach
                               {:desc "register lsp keymaps" : callback}))

;; setup
(vim.lsp.enable [:ast_grep
                 :bashls
                 :csharp_ls
                 :cssls
                 :dartls
                 :denols
                 :dhall_lsp_server
                 :efm
                 :fennel_ls
                 :gopls
                 :html
                 :jsonls
                 :kotlin_language_server
                 :lua_ls
                 :marksman
                 :nil_ls
                 :pyright
                 :solargraph
                 :taplo
                 :vtsls
                 :yamlls])
