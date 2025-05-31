; builtinのpopupとの干渉を回避する
(set vim.opt.completeopt [])
(vim.keymap.set :i :<C-Space> :<C-n> {:noremap true :noremap true})

(local cmp (require :blink.cmp))
(local types (require :blink.cmp.types))

(local keymap
       (let [lsp_provider (fn [cmp]
                            (cmp.show {:providers [:lsp]}))
             path_provider (fn [cmp]
                             (cmp.show {:providers [:path]}))]
         {:preset :none
          ;:<C-space> [:show :show_documentation :hide_documentation]
          :<C-x>l [:show lsp_provider]
          :<C-x><C-l> [:show lsp_provider]
          :<C-x>f [:show path_provider]
          :<C-x><C-f> [:show path_provider]
          :<C-e> [:hide]
          :<C-y> [:select_and_accept]
          :<C-p> [:select_prev :fallback_to_mappings]
          :<C-n> [:select_next :fallback_to_mappings]
          :<C-b> [:scroll_documentation_up :fallback]
          :<C-f> [:scroll_documentation_down :fallback]
          :<Tab> [:snippet_forward :fallback]
          :<S-Tab> [:snippet_backward :fallback]
          :<C-k> [:show_signature :hide_signature :fallback]}))

(local appearance {:nerd_font_variant :mono})
(local completion {:documentation {:auto_show false}})
(local sources {:default [:avante
                          ;:lsp
                          ;:path
                          :snippets
                          :buffer]
                :providers {:lsp {:fallbacks {}
                                  ; ignore keyword
                                  :transform_items (fn [_ items]
                                                     (-> (fn [item]
                                                           (not= item.kind
                                                                 types.CompletionItemKind.Keyword))
                                                         (vim.tbl_filter items)))}
                            :avante {:module :blink-cmp-avante
                                     :name :Avante
                                     :opts {}}}
                ; :snippets {:should_show_items (fn [ctx]
                ;                                 (not= ctx.trigger.initial_kind
                ;                                       :trigger_character))}
                })

;(local snippets {:preset :luasnip})
(local fuzzy
       {:implementation :prefer_rust_with_warning
        ;max_typos = function(keyword) return math.floor(#keyword / 4) end,
        :use_frecency true
        :use_proximity true
        :use_unsafe_no_lock false
        :sorts [:score :sort_text]
        :prebuilt_binaries {:download false
                            :ignore_version_mismatch false
                            :force_version nil
                            :force_system_triple nil
                            :extra_curl_args []
                            :proxy {:from_env true :url nil}}})

(cmp.setup {: keymap : appearance : completion : sources : fuzzy})

(vim.lsp.config "*" {:capabilities (cmp.get_lsp_capabilities)})
