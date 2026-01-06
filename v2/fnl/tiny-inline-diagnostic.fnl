(local diag (require :tiny-inline-diagnostic))

(diag.setup {:preset :classic
             :transparent_bg true
             :hi {:error :DiagnosticError
                  :warn :DiagnosticWarn
                  :info :DiagnosticInfo
                  :hint :DiagnosticHint
                  :arrow :NonText
                  :background :CursorLine
                  :mixing_color :None}
             :virt_texts {:priority 2048}})
