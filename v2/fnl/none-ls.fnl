(local null_ls (require :null-ls))
(local utils (require :null-ls.utils))
(local diagnostics null_ls.builtins.diagnostics)
(local formatting null_ls.builtins.formatting)

(fn lsp_active? [lsp_name]
  (let [bufnr (vim.api.nvim_get_current_buf)
        clients (vim.lsp.get_clients {: bufnr})]
    (accumulate [acc false _ client (ipairs clients)]
      (or acc (= lsp_name client.name)))))

(local sources [;;; code actions ;;;
                ;;; diagnostics ;;;
                diagnostics.actionlint
                diagnostics.checkmake
                diagnostics.checkstyle
                diagnostics.deadnix
                diagnostics.dotenv_linter
                diagnostics.editorconfig_checker
                diagnostics.gitlint
                diagnostics.hodolint
                diagnostics.ktlint
                diagnostics.selene
                diagnostics.staticcheck
                diagnostics.statix
                diagnostics.stylelint
                diagnostics.vint
                diagnostics.yamllint
                (. (require "none-ls.diagnostics.eslint"))
                ;;; completion ;;;
                ;;; formatting ;;;
                formatting.biome
                formatting.fantomas
                formatting.fnlfmt
                formatting.gofumpt
                formatting.goimports
                formatting.google_java_format
                formatting.ktlint
                formatting.nixfmt
                (formatting.prettier.with {:prefer_local :node_modules/.bin
                                           :runtime_condition (fn [...]
                                                                (not (lsp_active? :denols)))})
                formatting.shfmt
                formatting.stylelint
                formatting.stylua
                formatting.tidy
                formatting.yamlfmt
                formatting.yapf
                ;;; hover ;;;
                ])

(null_ls.setup {:border :none
                :cmd [:nvim]
                :debounce 300
                :debug false
                :default_timeout 50000
                :diagnostic_config {}
                :diagnostics_format "#{m}"
                :fallback_severity vim.diagnostic.severity.ERROR
                :log_level :warn
                :notify_format "[null-ls] %s"
                :on_attach nil
                :on_init nil
                :on_exit nil
                :root_dir (utils.root_pattern :.null-ls-root :Makefile :.git)
                :root_dir_async nil
                :should_attach nil
                :temp_dir nil
                :update_in_insert false
                : sources})
