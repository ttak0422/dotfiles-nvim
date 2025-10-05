; WIP
(let [aibo (require :aibo)
      prompt {:no_default_mappings false
              :on_attach (fn [bufnr _info]
                           (each [mode maps (pairs {[:n :i] {:<C-n> "<Plug>(aibo-send)<C-n>"
                                                             :<C-p> "<Plug>(aibo-send)<C-p>"
                                                             :<Down> "<Plug>(aibo-send)<Down>"
                                                             :<Up> "<Plug>(aibo-send)<Up>"
                                                             :<C-c> "<Plug>(aibo-send)<Esc>"}
                                                    [:n] {:<CR> "<Plug>(aibo-submit)"}
                                                    [:i] {:<C-s> "<Plug>(aibo-submit)"}})]
                             (each [k v (pairs maps)]
                               (vim.keymap.set mode k v
                                               {:buffer bufnr
                                                :nowait true
                                                :silent true}))))}
      console {:no_default_mappings false :on_attach (fn [_bufnr _info])}
      tools {:claude {:no_default_mappings false
                      :on_attach (fn [_bufnr _info])}
             :codex {}}]
  (aibo.setup {: prompt : console : tools}))
