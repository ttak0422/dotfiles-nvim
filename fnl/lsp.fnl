(local lsp (require :lspconfig))
(local climb (require :climbdir))
(local marker (require :climbdir.marker))
(local capabilities (dofile args.capabilities_path))

; ; ctags
; (lsp.ctags_lsp.setup {})

; lua
(lsp.lua_ls.setup {:settings {:Lua {:runtime {:version :LuaJIT
                                              :special {:reload :require}}
                                    :diagnostics {:globals [:vim]}}
                              :workspace {:library [(vim.fn.expand :$VIMRUNTIME/lua)]}
                              :telemetry {:enable false}}
                   : capabilities})

;; fennel
(lsp.fennel_ls.setup {:settings {:fennel-ls {:extra-globals :vim}}
                      : capabilities})

;; nix
(lsp.nil_ls.setup {:autostart true
                   :settings {:nil {:formatting {:command [:nixpkgs-fmt]}}}
                   : capabilities})

;; bash
(lsp.bashls.setup {: capabilities})

;; csharp
(lsp.csharp_ls.setup {: capabilities})

;; python
(lsp.pyright.setup {: capabilities})

;; ruby
(lsp.solargraph.setup {: capabilities})

;; toml
(lsp.taplo.setup {: capabilities})

; go
(lsp.gopls.setup {: capabilities})

;; dart
(lsp.dartls.setup {: capabilities})

;; dhall
(lsp.dhall_lsp_server.setup {: capabilities})

;; yaml
(lsp.yamlls.setup {:settings {:yaml {:keyOrdering false}} : capabilities})

;; html
(lsp.html.setup {: capabilities})

;; css, css, less
(lsp.cssls.setup {: capabilities})

;; json
(lsp.jsonls.setup {: capabilities})

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
                  :vtsls {:experimental {:completion {:enableServerSideFuzzyMatch true}}}
                  : capabilities})

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
                   :settings {:deno {:enable true}}
                   : capabilities})

;; markdown
(lsp.marksman.setup {: capabilities})

;; ast_grep
(lsp.ast_grep.setup {: capabilities})

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
                  : init_options
                  : capabilities}))

;; kotlin
(lsp.kotlin_language_server.setup {: capabilities})
