{:settings {:harper-ls {:userDictPath (.. (vim.fn.stdpath :state)
                                          :/harper/dictionary.txt)
                        ; :workspaceDictPath ""
                        ; :fileDictPath ""
                        :linters {:AnA true
                                  :CorrectNumberSuffix true
                                  :LongSentences false
                                  :Matcher true
                                  :OrthographicConsistency false
                                  :RepeatedWords true
                                  :SentenceCapitalization false
                                  :Spaces true
                                  :SpelledNumbers false
                                  :UnclosedQuotes true
                                  :WrongQuotes false
                                  :SpellCheck true}
                        ; :codeActions {:ForceStable false}
                        :markdown {:IgnoreLinkTitle true}
                        ; :diagnosticSeverity :hint
                        ; :isolateEnglish false
                        ; :dialect :American
                        ; :maxFileLength 120000
                        ; :ignoredLintsPath ""
                        ; :excludePatterns {}
                        }}}
