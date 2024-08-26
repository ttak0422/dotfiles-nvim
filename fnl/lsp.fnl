;; configured by bundler-nvim
(local on_attach (dofile args.on_attach_path))

(vim.diagnostic.config {:severity_sort true})
(vim.lsp.set_log_level :WARN)
(tset vim.lsp.handlers :textDocument/hover
      (vim.lsp.with vim.lsp.handlers.hover {:border :none}))

(let [signs [{:name :DiagnosticSignError :text ""}
             {:name :DiagnosticSignWarn :text ""}
             {:name :DiagnosticSignInfo :text ""}
             {:name :DiagnosticSignHint :text ""}]]
  (each [_ sign (ipairs signs)]
    (vim.fn.sign_define sign.name {:texthl sign.name :text sign.text :numhl ""})))

(local lspconfig (require :lspconfig))
;; (local util (require :lspconfig.util))
(local windows (require :lspconfig.ui.windows))
(local climb (require :climbdir))
(local marker (require :climbdir.marker))

(set windows.default_options.border :none)

;; lua
(lspconfig.lua_ls.setup {: on_attach
                         :settings {:Lua {:runtime {:version :LuaJIT}
                                          :diagnostics {:globals [:vim]}}
                                    :workspace {}
                                    :telemetry {:enable false}}})

;; fennel
(lspconfig.fennel_ls.setup {: on_attach
                            :settings {:fennel-ls {:extra-globals :vim}}})

;; nix
(lspconfig.nil_ls.setup {: on_attach
                         :autostart true
                         :settings {:nil {:formatting {:command [:nixpkgs-fmt]}}}})

;; bash
(lspconfig.bashls.setup {: on_attach})

;; csharp
(lspconfig.csharp_ls.setup {: on_attach})

;; python
(lspconfig.pyright.setup {: on_attach})

;; ruby
(lspconfig.solargraph.setup {: on_attach})

;; toml
(lspconfig.taplo.setup {: on_attach})

; go → use gopls
(lspconfig.gopls.setup {: on_attach
                        :settings {:gopls {:analyses {:unusedparams true
                                                      :unusedvariable true
                                                      :useany true}
                                           :staticcheck false}}})

;; dart
(lspconfig.dartls.setup {: on_attach})

;; dhall
(lspconfig.dhall_lsp_server.setup {: on_attach})

;; yaml
(lspconfig.yamlls.setup {: on_attach :settings {:yaml {:keyOrdering false}}})

;; html
(lspconfig.html.setup {: on_attach})

;; css, css, less
(lspconfig.cssls.setup {: on_attach})

;; json
(lspconfig.jsonls.setup {: on_attach})

;; typescript (node)
(lspconfig.vtsls.setup {: on_attach
                        :single_file_support false
                        :settings {:separate_diagnostic_server true
                                   :publish_diagnostic_on :insert_leave
                                   :typescript {:suggest {:completeFunctionCalls true}
                                                :preferences {:importModuleSpecifier :relative}}}
                        :root_dir (fn [path]
                                    (climb.climb path
                                                 (marker.one_of (marker.has_readable_file :package.json)
                                                                (marker.has_directory :node_modules))
                                                 {:halt (marker.one_of (marker.has_readable_file :deno.json))}))
                        :vtsls {:experimental {:completion {:enableServerSideFuzzyMatch true}}}})

;; typescript (deno)
(lspconfig.denols.setup {: on_attach
                         :single_file_support false
                         :root_dir (fn [path]
                                     (local found
                                            (climb.climb path
                                                         (marker.one_of (marker.has_readable_file :deno.json)
                                                                        (marker.has_readable_file :deno.jsonc)
                                                                        (marker.has_directory :denops))
                                                         {:halt (marker.one_of (marker.has_readable_file :package.json)
                                                                               (marker.has_directory :node_modules))}))
                                     (local buf (. vim.b (vim.fn.bufnr)))
                                     (when found
                                       (set buf.deno_deps_candidate
                                            (.. found :/deps.ts)))
                                     found)
                         :init_options {:lint true
                                        :unstable false
                                        :suggest {:completeFunctionCalls true
                                                  :names true
                                                  :paths true
                                                  :autoImports true
                                                  :imports {:autoDiscover true
                                                            :hosts (vim.empty_dict)}}}
                         :settings {:deno {:enable true}}})

;; markdown
(lspconfig.marksman.setup {: on_attach})

;; ast_grep
(lspconfig.ast_grep.setup {: on_attach})

;; efm
(let [luacheck (require :efmls-configs.linters.luacheck)
      eslint (require :efmls-configs.linters.eslint)
      yamllint (require :efmls-configs.linters.yamllint)
      statix (require :efmls-configs.linters.statix)
      stylelint (require :efmls-configs.linters.stylelint)
      vint (require :efmls-configs.linters.vint)
      shellcheck (require :efmls-configs.linters.shellcheck)
      pylint (require :efmls-configs.linters.pylint)
      gitlint (require :efmls-configs.linters.gitlint)
      hadolint (require :efmls-configs.linters.hadolint) ;;
      languages {:lua [luacheck]
                 :typescript [eslint]
                 :javascript [eslint]
                 :sh [shellcheck]
                 :yaml [yamllint]
                 :nix [statix]
                 :css [stylelint]
                 :scss [stylelint]
                 :less [stylelint]
                 :saas [stylelint]
                 :vim [vint]
                 :python [pylint]
                 :gitcommit [gitlint]
                 :docker [hadolint]}
      settings {:rootMarkers [:.git/] : languages}
      init_options {:documentFormatting true :documentRangeFormatting true}
      make_settings (fn []
                      {:single_file_support true
                       :filetypes (vim.tbl_keys languages)
                       : settings
                       : init_options
                       : on_attach})]
  (lspconfig.efm.setup (make_settings)))
