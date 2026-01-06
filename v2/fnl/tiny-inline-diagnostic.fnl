(local diag (require :tiny-inline-diagnostic))

(diag.setup {:preset :classic
             :transparent_bg true
             :hi {:error :GitSignsDelete
                  :warn :GitSignsAdd
                  :info :GitSignsChange
                  :arrow :NonText
                  :background :CursorLine
                  :mixing_color :None}
             :virt_texts {:priority 2048}
             :options {:severity [vim.diagnostic.severity.ERROR
                                  vim.diagnostic.severity.WARN
                                  vim.diagnostic.severity.INFO]}})
