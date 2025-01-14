(local lsp (require :lspconfig))
(local climb (require :climbdir))
(local marker (require :climbdir.marker))

; ; ctags
; (lsp.ctags_lsp.setup {})

; lua
(lsp.lua_ls.setup {:settings {:Lua {:runtime {:version :LuaJIT
                                              :special {:reload :require}}
                                    :diagnostics {:globals [:vim]}}
                              :workspace {:library [(vim.fn.expand :$VIMRUNTIME/lua)]}
                              :telemetry {:enable false}}})

;; fennel
(lsp.fennel_ls.setup {:settings {:fennel-ls {:extra-globals :vim}}})

;; nix
(lsp.nil_ls.setup {:autostart true
                   :settings {:nil {:formatting {:command [:nixpkgs-fmt]}}}})

;; bash
(lsp.bashls.setup {})

;; csharp
(lsp.csharp_ls.setup {})

;; python
(lsp.pyright.setup {})

;; ruby
(lsp.solargraph.setup {})

;; toml
(lsp.taplo.setup {})

; go
(lsp.gopls.setup {})

;; dart
(lsp.dartls.setup {})

;; dhall
(lsp.dhall_lsp_server.setup {})

;; yaml
(lsp.yamlls.setup {:settings {:yaml {:keyOrdering false}}})

;; html
(lsp.html.setup {})

;; css, css, less
(lsp.cssls.setup {})

;; json
(lsp.jsonls.setup {})

;; typescript (node)
(lsp.vtsls.setup {:single_file_support false
                  :settings {:separate_diagnostic_server true
                             :publish_diagnostic_on :insert_leave
                             :typescript {:suggest {:completeFunctionCalls true}
                                          :preferences {:importModuleSpecifier :relative}}}
                  :root_dir (fn [path]
                              (climb.climb path
                                           (marker.one_of (marker.has_readable_file :package.json)
                                                          (marker.has_directory :node_modules))
                                           {:halt (marker.one_of (marker.has_readable_file :deno.json))}))
                  :flags {:debounce_text_changes 1000}
                  :vtsls {:experimental {:completion {:enableServerSideFuzzyMatch true}}}})

;; typescript (deno)
(lsp.denols.setup {:single_file_support false
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
(lsp.marksman.setup {})

;; ast_grep
(lsp.ast_grep.setup {})

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
      init_options {:documentFormatting true :documentRangeFormatting true}]
  (lsp.efm.setup {:single_file_support true
                  :filetypes (vim.tbl_keys languages)
                  : settings
                  : init_options}))

;; kotlin
(lsp.kotlin_language_server.setup {})
