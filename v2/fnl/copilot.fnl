(local copilot (require :copilot))

(copilot.setup {:panel {:auto_refresh false
                        :keymap {:jump_prev "[["
                                 :jump_next "]]"
                                 :accept :<CR>
                                 :refresh :gr
                                 :open :<M-CR>}
                        :layout {:position :bottom :ratio 0.4}}
                :suggestion {:enabled (or vim.g.copilot false)
                             :auto_trigger true
                             :hide_during_completion true
                             :debounce 150
                             :keymap {:accept :<C-x><C-x>
                                      :accept_word false
                                      :accept_line false
                                      :next "<M-]>"
                                      :prev "<M-[>"
                                      :dismiss :<M-e>}}
                :filetypes {:help false :gitrebase false :. false}
                :nes {:enabled true
                      :auto_trigger false
                      :keymap {:accept_and_goto :<Tab>
                               :accept false
                               :dismiss :<Esc>}}})
