(let [cmp (require :blink.cmp)
      keymap {:preset :default}
      appearance {:nerd_font_variant :mono}
      completion {:documentation {:auto_show false}}
      sources {:default [:lsp :path :snippets :buffer]}
      fuzzy {:implementation :prefer_rust_with_warning
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
                                 :proxy {:from_env true :url nil}}}]
  (cmp.setup {: keymap : appearance : completion : sources : fuzzy}))

(vim.lsp.config "*"
                {:capabilities ((. (require :blink.cmp) :get_lsp_capabilities))})
