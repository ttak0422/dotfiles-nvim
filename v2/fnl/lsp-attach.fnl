(macro cmd [c]
  `,(.. :<Cmd> c :<CR>))

(fn [ctx]
  (if (not vim.b.lsp_attached)
      (do
        (set vim.b.lsp_attached true)
        (let [bufnr ctx.buf
              desc (fn [d]
                     {:noremap true :silent true :buffer bufnr :desc d})]
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
                              [:<Leader>ca
                               vim.lsp.buf.code_action
                               "code action"]
                              ; plugin
                              [:K
                               #(let [(ok noice_lsp) (pcall require :noice.lsp)]
                                  (if ok
                                      (noice_lsp.hover) ; https://github.com/neovim/nvim-lspconfig/issues/3036
                                      (vim.lsp.buf.hover) ; fallback
                                      ))
                               "show doc"]
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
                           :buffer bufnr
                           :desc :rename})
          (vim.keymap.set :n :<leader>cF vim.lsp.buf.format (desc " format"))
          (vim.keymap.set [:n :v] :<C-CR>
                          #(vim.lsp.buf.format {:timeout_ms 10000})
                          (desc " format"))))))
