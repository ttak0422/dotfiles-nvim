{:settings {:harper-ls {:userDictPath (.. (vim.fn.stdpath :state)
                                          :/harper/dictionary.txt)
                        ; :workspaceDictPath ""
                        ; :fileDictPath ""
                        :linters {:SpellCheck true
                                  :SpelledNumbers false
                                  :AnA true
                                  :SentenceCapitalization false
                                  :UnclosedQuotes true
                                  :WrongQuotes false
                                  :LongSentences true
                                  :RepeatedWords true
                                  :Spaces true
                                  :Matcher true
                                  :CorrectNumberSuffix true}
                        ; :codeActions {:ForceStable false}
                        :markdown {:IgnoreLinkTitle true}
                        ; :diagnosticSeverity :hint
                        ; :isolateEnglish false
                        ; :dialect :American
                        ; :maxFileLength 120000
                        ; :ignoredLintsPath ""
                        ; :excludePatterns {}
                        }}}
