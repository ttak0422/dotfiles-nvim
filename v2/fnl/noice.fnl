(local noice (require :noice))

(local lsp {:progress {:enabled true}
            :signature {:enabled false}
            :hover {:silent true}
            :override {:vim.lsp.util.convert_input_to_markdown_lines true
                       :vim.lsp.util.stylize_markdown true}})

(local routes [{:filter {:event :lsp
                         :kind :progress
                         :any [{:cond (fn [message]
                                        (= (vim.tbl_get message.opts :progress
                                                        :client)
                                           :null-ls))}]}
                :opts {:skip true}}])

(noice.setup {: lsp : routes})
