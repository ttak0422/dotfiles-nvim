(local copilot (require :copilot))

(local panel {:auto_refresh false
              :keymap {:jump_prev "[["
                       :jump_next "]]"
                       :accept :<CR>
                       :refresh :gr
                       :open :<M-CR>}
              :layout {:position :bottom :ratio 0.4}})

(local suggestion {:enabled (or vim.g.copilot false)
                   :auto_trigger true
                   :hide_during_completion true
                   :debounce 150
                   :keymap {:accept :<C-x><C-x>
                            :accept_word false
                            :accept_line false
                            :next "<M-]>"
                            :prev "<M-[>"
                            :dismiss :<M-e>}})

(local filetypes {:help false :gitrebase false :. false})

(copilot.setup {: panel : suggestion : filetypes})
