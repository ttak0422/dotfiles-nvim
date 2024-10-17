((. (require :tiny-inline-diagnostic) :setup) {:signs {:left ""
                                                       :right ""
                                                       :diag " "
                                                       :arrow "   "
                                                       :up_arrow "   "
                                                       :vertical " │"
                                                       :vertical_end " └"}
                                               :hi {:error :DiagnosticError
                                                    :warn :DiagnosticWarn
                                                    :info :DiagnosticInfo
                                                    :hint :DiagnosticHint
                                                    :arrow :NonText
                                                    :background :CursorLine
                                                    :mixing_color :None}
                                               :blend {:factor 0.27}
                                               :options {:show_source false
                                                         :throttle 20
                                                         :softwrap 15
                                                         :multiple_diag_under_cursor false
                                                         :multilines false
                                                         :show_all_diags_on_cursorline false
                                                         :overflow {:mode :none}
                                                         :format nil
                                                         :break_line {:enabled false
                                                                      :after 30}
                                                         :virt_texts {:priority 2048}
                                                         :severity {vim.diagnostic.severity.ERROR vim.diagnostic.severity.WARN
                                                                    vim.diagnostic.severity.INFO vim.diagnostic.severity.HINT}
                                                         :overwrite_events nil}})
