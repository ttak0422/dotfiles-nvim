(local noice (require :noice))

(local lsp {:progress {:enabled true}
            :signature {:enabled false}
            :hover {:silent true}
            :override {:vim.lsp.util.convert_input_to_markdown_lines true
                       :vim.lsp.util.stylize_markdown true}})

(local routes [{:filter {:event :lsp
                         :kind :progress
                         :any [{:cond (fn [message]
                                        (case (vim.tbl_get message.opts
                                                           :progress :client)
                                          :null-ls true
                                          :jdtls (let [title (vim.tbl_get message.opts
                                                                          :progress
                                                                          :title)]
                                                   (or (= title
                                                          "Publish Diagnostics")
                                                       (= title
                                                          "Validate documents")
                                                       (and (= title
                                                               "Background task")
                                                            (= (vim.tbl_get message.opts
                                                                            :progress
                                                                            :percentage)
                                                               0))))
                                          _ false))}]}
                :opts {:skip true}}])

(noice.setup {: lsp
              : routes
              :cmdline {:enabled false}
              :messages {:enabled false}})
