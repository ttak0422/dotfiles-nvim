(fn [client bufnr]
  (let [map vim.keymap.set
        cmd (fn [c] (.. :<cmd> c :<cr>))
        desc (fn [d] {:noremap true :silent true :buffer bufnr :desc d})
        inlayhints (require :lsp-inlayhints)]
    ;; register commands
    (vim.api.nvim_create_user_command :Format "lua vim.lsp.buf.format()" {})
    ;; jump
    (map :n :gd vim.lsp.buf.definition (desc "go to definition"))
    (map :n :gi vim.lsp.buf.implementation (desc "go to impl"))
    (map :n :gr vim.lsp.buf.references (desc "go to references"))
    (map :n :gD (cmd "Glance definitions") (desc "go to definition"))
    (map :n :gI (cmd "Glance implementations") (desc "go to impl"))
    (map :n :gR (cmd "Glance references") (desc "go to references"))
    ;; action
    (map :n :K vim.lsp.buf.hover (desc "show doc"))
    (map :n :<leader>K vim.lsp.buf.signature_help (desc "show signature"))
    (map :n :<leader>D vim.lsp.buf.type_definition (desc "show type"))
    (map :n :<leader>rn vim.lsp.buf.rename (desc :rename))
    (map :n :<leader>ca vim.lsp.buf.code_action (desc "code action"))
    (map :n :<leader>cc (cmd "Neogen class") (desc "class comment"))
    (map :n :<leader>J
         (cmd "lua require('treesj').toggle({ split = { recursive = false }})")
         (desc "toggle split/join"))
    (map :n :<leader>cf (cmd "Neogen func") (desc "fn comment"))
    (if (client.supports_method :textDocument/formatting)
        (map :n :<leader>cF (cmd :Format) (desc :format)))
    ;; info
    (if (client.supports_method :textDocument/inlayHint)
        (inlayhints.on_attach client bufnr false))
    (if (client.supports_method :textDocument/publishDiagnostics)
        ;; delay update diagnostics
        (set vim.lsp.handlers.textDocument/publishDiagnostics
             (vim.lsp.with vim.lsp.diagnostic.on_publish_diagnostics
               {:update_in_insert false})))))
