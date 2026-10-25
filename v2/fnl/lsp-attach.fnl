(macro cmd [c]
  `,(.. :<Cmd> c :<CR>))

;; { buf, client }
(fn [ctx]
  (when (and ctx.client
             (ctx.client:supports_method :textDocument/inlayHint ctx.buf))
    (vim.lsp.inlay_hint.enable true {:bufnr ctx.buf}))
  (if (not vim.b.lsp_attached)
      (do
        (set vim.b.lsp_attached true)
        (let [bufnr ctx.buf
              desc (fn [d]
                     {:noremap true :silent true :buf bufnr :desc d})]
          (each [_ k (ipairs [; builtin
                              [:gd
                               vim.lsp.buf.definition
                               ;; #((. (require :lookup) :lookup_definition))
                               "go to definition"]
                              [:gi
                               vim.lsp.buf.implementation
                               "go to implementation"]
                              [:gr vim.lsp.buf.references "go to references"]
                              [:<Leader>K
                               vim.lsp.buf.signature_help
                               "show signature"]
                              [:<Leader>D
                               vim.lsp.buf.type_definition
                               "show type"]
                              ; plugin
                              [:<Leader>ca
                               #((. (require :tiny-code-action) :code_action))
                               "code action"]
                              [:gpd
                               (cmd "lua require('goto-preview').goto_preview_definition()")
                               "preview definition"]
                              [:gpi
                               (cmd "lua require('goto-preview').goto_preview_implementation()")
                               "preview implementation"]
                              [:gpr
                               (cmd "lua require('goto-preview').goto_preview_references()")
                               "preview references"]
                              [:gP
                               (cmd "lua require('goto-preview').close_all_win()")
                               "close all preview"]
                              [:gD
                               (cmd "Glance definitions")
                               "go to definition"]
                              [:gI (cmd "Glance implementations") "go to impl"]
                              [:gR
                               (cmd "Glance references")
                               "go to references"]
                              [:<leader>cc
                               (cmd "Neogen class")
                               "class comment"]
                              [:<leader>cf (cmd "Neogen func") "fn comment"]
                              [:<leader>rn ":IncRename " :rename]])]
            (vim.keymap.set :n (. k 1) (. k 2) (desc (.. " " (. k 3)))))
          (vim.keymap.set :n :<leader>rN
                          (fn []
                            (.. ":IncRename " (vim.fn.expand :<cword>)))
                          {:noremap true
                           :silent true
                           :expr true
                           :buf bufnr
                           :desc :rename})
          ;; none-ls owns JVM formatting, including the explicit IDEA/GJF choice.
          ;; Allow the 60s IDEA process deadline plus response/cleanup overhead.
          (local format (fn [timeout]
                          (local jvm (. {:java true :groovy true :kotlin true}
                                        vim.bo.filetype))
                          (vim.lsp.buf.format {:timeout_ms (if jvm 65000 timeout)
                                               :name (when jvm :null-ls)})))
          (vim.keymap.set :n :<leader>cF #(format 1000) (desc " format"))
          (vim.keymap.set [:n :v] :<C-CR>
                          #(format 10000)
                          (desc " format"))))))
