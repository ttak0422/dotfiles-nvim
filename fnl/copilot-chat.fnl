(let [P (require :CopilotChat.prompts)
      S (require :CopilotChat.select)
      namespace (vim.api.nvim_create_namespace :copilot_review)
      selection (fn [src]
                  (or (S.visual src) (S.line src)))
      prompts {:Explain {:prompt "/COPILOT_EXPLAIN 選択されたコードを解説してください."}
               :Review {:prompt "/COPILOT_REVIEW 選択されたコードのレビューをしてください."
                        :callback (fn [res src]
                                    (let [bufnr src.bufnr
                                          diagnostics (icollect [line (res:gmatch "[^\r\n]+")]
                                                        (if (line:find :^line=)
                                                            (let [(single msg) (line:match "^line=(%d+): (.*)$")
                                                                  t (if single
                                                                        {:start (tonumber single)
                                                                         :end (tonumber single)
                                                                         :message msg}
                                                                        (let [(start end
                                                                                     msg) (line:match "^line=(%d+)-(%d+): (.*)$")]
                                                                          {:start (tonumber start)
                                                                           :end (tonumber end)
                                                                           :message msg}))]
                                                              (if (and t.start
                                                                       t.end)
                                                                  {:lnum (- t.start
                                                                            1)
                                                                   :end_lnum (- t.end
                                                                                1)
                                                                   :col 0
                                                                   :message t.message
                                                                   :severity vim.diagnostic.severity.WARN
                                                                   :source "Copilot Review"}))))]
                                      (vim.diagnostic.set namespace bufnr
                                                          diagnostics)))}
               :Fix {:prompt "/COPILOT_GENERATE コード中にバグが含まれています.不具合を修正したコードを提示してください."}
               :Optimize {:prompt "/COPILOT_GENERATE 選択したコードのパフォーマンスと可読性を向上させてください."}
               :Docs {:prompt "/COPILOT_GENERATE 選択したコードのDocCommentを整備してください."}
               :Tests {:prompt "/COPILOT_GENERATE 選択したコードのテストコードを生成してください."}
               :FixDiagnostic {:prompt "ファイル中のdiagnosticsに対応するコードを提示してください."
                               :selection S.diagnostics}
               :Commit {:prompt "コミットメッセージを規約に沿って記述してください. (タイトルは50文字以内,メッセージは72文字で改行する)"
                        :selection S.gitdiff}
               :CommitStaged {:prompt "コミットメッセージを規約に沿って記述してください. (タイトルは50文字以内,メッセージは72文字で改行する)"
                              :selection (fn [src]
                                           (S.gitdiff src true))}}
      window {:layout :float
              :width 0.5
              :height 0.5
              :relative :editor
              :border :none
              :row nil
              :col nil
              :title "Copilot Chat"
              :footer nil
              :zindex 1}
      mappings {:complete {:insert :<Tab>}
                :close {:normal :q :insert :<C-c>}
                :reset {:normal :<C-l> :insert :<C-l>}
                :submit_prompt {:normal :<CR> :insert :<C-s>}
                :accept_diff {:normal :<C-y> :insert :<C-y>}
                :yank_diff {:normal :gy :register "\""}
                :show_diff {:normal :gd}
                :show_info {:normal :gi}
                :show_context {:normal :gu}
                :show_help {:normal :g?}}
      opts {:debug false
            :proxy nil
            :allow_insecure false
            :system_prompt P.COPILOT_INSTRUCTIONS
            :model :gpt-4o
            :temperature 0.1
            :question_header " User "
            :answer_header " Copilot "
            :error_header " Error "
            :separator "───"
            :show_folds false
            :show_help true
            :auto_follow_cursor true
            :auto_insert_mode false
            :insert_at_end false
            :clear_chat_on_new_prompt false
            :highlight_selection true
            :context nil
            :callback nil
            : selection
            : prompts
            : window
            : mappings}]
  ((. (require :CopilotChat) :setup) opts))
