(local null_ls (require :null-ls))
(local diagnostics null_ls.builtins.diagnostics)
(local formatting null_ls.builtins.formatting)
(local utils (require :null-ls.utils))
(local helpers (require :null-ls.helpers))
(local methods (require :null-ls.methods))
(local FORMATTING methods.internal.FORMATTING)

(set vim.g.idea_path args.idea)

(local sources [;;; code actions ;;;
                ;;; diagnostics ;;;
                diagnostics.actionlint
                diagnostics.checkmake
                ; TODO: idea inspect ?
                ; <headless_idea_path>/Applications/IntelliJ\ IDEA\ CE.app/Contents/MacOS/idea \
                ; -Didea.config.path=~/Library/Application\ Support/JetBrains/<versions>/options/ \
                ; inspect \
                ; <target_path>
                ; .idea/inspectionProfiles/Project_Default.xml  \
                ; /tmp/profile
                (diagnostics.checkstyle.with {:runtime_condition #(not= vim.g.checkstyle
                                                                        nil)
                                              :extra_args [:-c
                                                           (or vim.g.checkstyle
                                                               :/google_checks.xml)]})
                diagnostics.deadnix
                diagnostics.dotenv_linter
                (diagnostics.editorconfig_checker.with {:runtime_condition (fn [ps]
                                                                             (not= ps.bufname
                                                                                   ""))})
                diagnostics.gitlint
                ; TODO:
                ; diagnostics.hodolint
                diagnostics.ktlint
                diagnostics.mypy
                diagnostics.selene
                diagnostics.semgrep
                diagnostics.sqruff
                diagnostics.staticcheck
                diagnostics.statix
                diagnostics.stylelint
                diagnostics.terraform_validate
                diagnostics.vint
                diagnostics.yamllint
                (formatting.prettier.with {:prefer_local :node_modules/.bin
                                           :runtime_condition (fn [params]
                                                                (let [bufname (vim.api.nvim_buf_get_name params.bufnr)
                                                                      targets [:tsconfig.json
                                                                               :package.json
                                                                               :jsconfig.json
                                                                               :.node_project]]
                                                                  (vim.fs.root bufname
                                                                               targets)))
                                           :filetypes [:javascript
                                                       :javascriptreact
                                                       :typescript
                                                       :typescriptreact
                                                       :vue
                                                       :css
                                                       :scss
                                                       :less
                                                       ; :html
                                                       ; :json
                                                       ; :jsonc
                                                       ; :yaml
                                                       ; :markdown
                                                       ; :markdown.mdx
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
                ; `vim.g.idea_format`が設定されている場合ideaを利用する
                (helpers.make_builtin {:name :idea
                                       :method FORMATTING
                                       :filetypes [:java :groovy :kotlin]
                                       :runtime_condition #(not= vim.g.idea_format
                                                                 nil)
                                       :generator_opts {:command args.idea
                                                        :args #[:format
                                                                :-s
                                                                vim.g.idea_format
                                                                :$FILENAME]
                                                        :timeout 20000
                                                        :to_stdin false
                                                        :from_temp_file true
                                                        :to_temp_file true}
                                       :factory helpers.formatter_factory})
                (formatting.google_java_format.with {:runtime_condition #(= vim.g.idea_format
                                                                            nil)
                                                     :timeout 20000})
                formatting.ktlint
                formatting.nixfmt
                formatting.shfmt
                formatting.sqruff
                formatting.stylelint
                formatting.stylua
                formatting.terraform_fmt
                formatting.tidy
                formatting.yamlfmt
                formatting.yapf
                ;;; hover ;;;
                ])

(null_ls.setup {:border :none
                :cmd [:nvim]
                :debounce 300
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
                : sources})

(vim.api.nvim_create_user_command :NoneLsInfo #(vim.cmd :NullLsInfo) {})
(vim.api.nvim_create_user_command :NoneLsLog #(vim.cmd :NullLsLog) {})
