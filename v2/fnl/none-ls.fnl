(local null_ls (require :null-ls))
(local diagnostics null_ls.builtins.diagnostics)
(local formatting null_ls.builtins.formatting)
(local utils (require :null-ls.utils))
(local sources [;;; code actions ;;;
                ;;; diagnostics ;;;
                diagnostics.actionlint
                diagnostics.checkmake
                diagnostics.checkstyle
                diagnostics.deadnix
                diagnostics.dotenv_linter
                diagnostics.editorconfig_checker
                diagnostics.gitlint
                ; TODO:
                ; diagnostics.hodolint
                diagnostics.ktlint
                diagnostics.selene
                diagnostics.staticcheck
                diagnostics.statix
                diagnostics.stylelint
                diagnostics.vint
                diagnostics.yamllint
                (formatting.prettier.with {:prefer_local :node_modules/.bin
                                           ; `condition`は起動時に固定されるため利用しない
                                           ; LSPの判定と同様の値を利用する。Activeになるものの適用されない。
                                           :runtime_condition #((. (require :null-ls.utils)
                                                                   :root_has_file) [:tsconfig.json
                                                                                    :package.json
                                                                                    :jsconfig.json
                                                                                    :.node_project])
                                           :filetypes [:javascript
                                                       :javascriptreact
                                                       :typescript
                                                       :typescriptreact
                                                       :vue
                                                       :css
                                                       :scss
                                                       :less
                                                       ; use tidy
                                                       ; :html
                                                       :json
                                                       :jsonc
                                                       ; use yamlfmt
                                                       ; :yaml
                                                       :markdown
                                                       :markdown.mdx
                                                       :graphql
                                                       :handlebars
                                                       :svelte
                                                       :astro
                                                       :htmlangular]})
                (. (require :none-ls.diagnostics.eslint))
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
                :default_timeout 20000
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
                : sources})

(vim.api.nvim_create_user_command :NoneLsInfo #(vim.cmd :NullLsInfo) {})
(vim.api.nvim_create_user_command :NoneLsLog #(vim.cmd :NullLsLog) {})
