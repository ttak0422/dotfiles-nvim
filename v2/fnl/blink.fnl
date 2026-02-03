; builtinのpopupとの干渉を回避する
(set vim.opt.completeopt [])
(each [lhs rhs (pairs {:<C-Space> :<C-n>
                       :<C-S-Space> :<C-p>
                       :<C-a> :<Home>
                       :<C-e> :<End>})]
  (vim.keymap.set :i lhs rhs {:noremap true}))

(vim.cmd "
cnoremap <expr> <C-a> '<Home>'
cnoremap <expr><C-e> '<End>'
cnoremap <expr> <C-b> '<Left>'
cnoremap <expr> <C-f> '<Right>'
         ")

(local cmp (require :blink.cmp))
(local types (require :blink.cmp.types))
(local keymap
       {:preset :none
        :<C-e> [:cancel
                :fallback_to_mappings
                (fn [cmp]
                  (if (cmp.is_visible)
                      (cmp.hide) true))
                :fallback_to_mappings]
        :<C-y> [:select_and_accept]
        :<C-p> [:select_prev :fallback_to_mappings]
        :<C-n> [:select_next :fallback_to_mappings]
        :<C-b> [:scroll_documentation_up :fallback]
        :<C-f> [:scroll_documentation_down :fallback]
        :<Tab> [:snippet_forward :fallback]
        :<S-Tab> [:snippet_backward :fallback]
        :<C-k> [:show_signature :hide_signature :fallback]})

(local signature {:enabled true})

(local completion {:accept {:auto_brackets {:enabled true
                                            :force_allow_filetypes []
                                            :blocked_filetypes []
                                            :kind_resolution {:enabled true
                                                              :blocked_filetypes [:typescriptreact
                                                                                  :javascriptreact
                                                                                  :vue
                                                                                  :kotlin]}
                                            :semantic_token_resolution {:enabled true
                                                                        :blocked_filetypes [:java]
                                                                        :timeout_ms 400}}
                            :resolve_timeout_ms 150}
                   :documentation {:auto_show true
                                   :auto_show_delay_ms 500
                                   :update_delay_ms 100
                                   :treesitter_highlighting true}
                   :keyword {:range :prefix}
                   :menu {:draw {:columns [[:kind_icon
                                            ; :kind
                                            ]
                                           [:label :label_description]
                                           ;[:source_name]
                                           ]}}})

(local appearance {:nerd_font_variant :mono
                   :kind_icons {:Text "󰉿"
                                :Method "󰊕"
                                :Function "󰊕"
                                :Constructor "󰒓"
                                :Field "󰜢"
                                :Variable "󰀫"
                                :Property "󰜢"
                                :Class "󰠱"
                                :Interface ""
                                :Struct "󰙅"
                                :Module ""
                                :Unit ""
                                :Value "󰎠"
                                :Enum ""
                                :EnumMember ""
                                :Keyword "󰌋"
                                :Constant "󰏿"
                                :Snippet ""
                                :Color "󰏘"
                                :File "󰈔"
                                :Reference "󰈇"
                                :Folder "󰉋"
                                :Event "󱐋"
                                :Operator "󰆕"
                                :TypeParameter "󰗴"}})

(local cmdline (let [search_src [:buffer]
                     cmd_src [:cmdline :buffer]]
                 {:enabled true
                  :keymap {:preset :none
                           :<Tab> [:show_and_insert_or_accept_single
                                   :select_next]
                           :<S-Tab> [(fn [cmp]
                                       cmp.show_and_insert_or_accept_single
                                       {:initial_selected_item_idx -1})
                                     :select_prev]
                           :<C-space> [:show :fallback]
                           :<C-n> [:select_next :fallback]
                           :<C-p> [:select_prev :fallback]
                           :<Right> [:select_next :fallback]
                           :<Left> [:select_prev :fallback]
                           :<C-y> [:select_and_accept :fallback]
                           :<C-e> [:cancel :fallback_to_mappings]
                           :<End> [:hide :fallback]}
                  :sources #(case (vim.fn.getcmdtype)
                              "/" search_src
                              "?" search_src
                              ":" cmd_src
                              "@" cmd_src)}))

(local term {:enabled false})

(local sources {:default [:lsp
                          ; :path
                          :snippets
                          :buffer]
                :per_filetype {; :markdown [:lsp
                               ;            :path
                               ;            :buffer
                               ;            :obsidian
                               ;            :obsidian_new
                               ;            :obsidian_tags]
                               }
                :providers {:lsp {:fallbacks {}
                                  :min_keyword_length (fn [ctx]
                                                        (case ctx.trigger.initial_kind
                                                          :trigger_character 0
                                                          :manual 0
                                                          _ 100))
                                  :transform_items (fn [_ items]
                                                     (-> (fn [item]
                                                           (not= item.kind
                                                                 types.CompletionItemKind.Keyword))
                                                         (vim.tbl_filter items)))}
                            :snippets {:should_show_items (fn [ctx]
                                                            (not= ctx.trigger.initial_kind
                                                                  :trigger_character))}}
                :min_keyword_length (fn [_ctx] 2)})

(local snippets {:preset :luasnip})
(local fuzzy
       {:implementation :rust
        ;max_typos = function(keyword) return math.floor(#keyword / 4) end,
        :frecency {:enabled true
                   :path (.. (vim.fn.stdpath :state) :/blink/cmp/frecency.dat)
                   :unsafe_no_lock false}
        :use_proximity true
        :sorts [:score :sort_text]
        :prebuilt_binaries {:download false
                            :ignore_version_mismatch false
                            :force_version nil
                            :force_system_triple nil
                            :extra_curl_args []
                            :proxy {:from_env true :url nil}}})

(cmp.setup {: completion
            : signature
            : appearance
            : fuzzy
            : keymap
            : sources
            : snippets
            : cmdline
            : term})

(vim.lsp.config "*" {:capabilities (cmp.get_lsp_capabilities)})

; WIP https://github.com/Saghen/blink.cmp/pull/487
(let [opts {:noremap true :silent true}
      lsp_provider #(cmp.show {:providers [:lsp]})
      path_provider #(cmp.show {:providers [:path]})]
  (each [_ k (ipairs [[:<C-x>l lsp_provider]
                      [:<C-x><C-l> lsp_provider]
                      [:<C-x>f path_provider]
                      [:<C-x><C-f> path_provider]])]
    (vim.keymap.set :i (. k 1) (. k 2) (or (. k 3) opts))))
