(let [M (require :tiny-inline-diagnostic)
      hi {:error :DiagnosticError
          :warn :DiagnosticWarn
          :info :DiagnosticInfo
          :hint :DiagnosticHint
          :arrow :NonText
          :background :Normal
          :mixing_color :None}
      options {:show_source false
               :use_icons_from_diagnostic false
               :add_messages true
               :throttle 150
               :softwrap 50
               :multiple_diag_under_cursor false
               :multilines {:enabled false :always_show false}
               :show_all_diags_on_cursorline false
               :enable_on_insert false
               :enable_on_select false
               :overflow {:mode :wrap}
               :break_line {:enabled false :after 50}
               :format nil
               :virt_texts {:priority 2048}
               :severity [vim.diagnostic.severity.ERROR
                          vim.diagnostic.severity.WARN
                          vim.diagnostic.severity.INFO
                          vim.diagnostic.severity.HINT]
               :overwrite_events nil}]
  (M.setup {:preset :simple : hi : options}))
