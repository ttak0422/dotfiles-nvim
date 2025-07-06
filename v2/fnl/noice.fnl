(local noice (require :noice))

(local lsp {:progress {:enabled false}
            :signature {:enabled false}
            :hover {:silent true}
            :override {:vim.lsp.util.convert_input_to_markdown_lines true
                       :vim.lsp.util.stylize_markdown true}})

(noice.setup {: lsp})
