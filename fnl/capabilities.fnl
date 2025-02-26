(let [capabilities (vim.lsp.protocol.make_client_capabilities)]
  (tset capabilities :textDocument.completion
        {:dynamicRegistration false
         :completionItem {:snippetSupport true
                          :commitCharactersSupport true
                          :deprecatedSupport true
                          :preselectSupport true
                          :tagSupport {:valueSet [1
                                                  ;; deprecated
                                                  ]}
                          :insertReplaceSupport true
                          :resolveSupport {:properties [:documentation
                                                        :detail
                                                        :additionalTextEdits
                                                        :insertText
                                                        :textEdit
                                                        :insertTextFormat
                                                        :insertTextMode]}
                          :insertTextModeSupport {:valueSet [1
                                                             ;; asIs
                                                             2
                                                             ;; adjustIndentation
                                                             ]}
                          :labelDetailsSupport true}
         :contextSupport true
         :insertTextMode 1
         :completionList {:itemDefaults [:commitCharacters
                                         :editRange
                                         :insertTextFormat
                                         :insertTextMode
                                         :data]}})
  capabilities)
