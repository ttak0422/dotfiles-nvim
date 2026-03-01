;; vim.env.ANTHROPIC_API_KEY=...
(pcall dofile (.. vim.env.HOME :/.config/nvim/avante.lua))

(local avante (require :avante))
(local lib (require :avante_lib))

(lib.load)

(local behaviour {:auto_focus_sidebar false
                  :auto_suggestions false
                  :auto_suggestions_respect_ignore false
                  :auto_set_highlight_group true
                  :auto_set_keymaps true
                  :auto_apply_diff_after_generation false
                  :jump_result_buffer_on_finish false
                  :support_paste_from_clipboard true
                  :minimize_diff true
                  :enable_token_counting true
                  :use_cwd_as_project_root false
                  :auto_focus_on_diff_view false
                  :auto_approve_tool_permissions true
                  :auto_check_diagnostics true
                  :enable_fastapply false
                  :include_generated_by_commit_line false
                  :auto_add_current_file false
                  :confirmation_ui_style :inline_buttons
                  :acp_follow_agent_locations false})

(local mappings
       (let [diff {:ours :co
                   :theirs :ct
                   :all_theirs :ca
                   :both :cb
                   :cursor :cc
                   :next "]x"
                   :prev "[x"}
             suggestion {:accept :<M-l>
                         :next "<M-]>"
                         :prev "<M-[>"
                         :dismiss :<M-e>}
             jump {:next "]]" :prev "[["}
             submit {:normal :<CR> :insert :<C-s>}
             cancel {:normal [:<C-c> :<Esc> :q] :insert [:<C-c>]}
             sidebar {:apply_all :A
                      :apply_cursor :a
                      :retry_user_request :r
                      :edit_user_request :e
                      :switch_windows :<Tab>
                      :reverse_switch_windows :<S-Tab>
                      :remove_file :d
                      :add_file "@"
                      :close [:q]
                      :close_from_input {:normal :q}}]
         {: diff : suggestion : jump : submit : cancel : sidebar}))

(local windows {:position :left
                :fillchars "eob: "
                :wrap true
                :width 30
                :height 50
                :sidebar_header {:enabled false :align :center :rounded false}
                :spinner {:editing ["⡀"
                                    "⠄"
                                    "⠂"
                                    "⠁"
                                    "⠈"
                                    "⠐"
                                    "⠠"
                                    "⢀"
                                    "⣀"
                                    "⢄"
                                    "⢂"
                                    "⢁"
                                    "⢈"
                                    "⢐"
                                    "⢠"
                                    "⣠"
                                    "⢤"
                                    "⢢"
                                    "⢡"
                                    "⢨"
                                    "⢰"
                                    "⣰"
                                    "⢴"
                                    "⢲"
                                    "⢱"
                                    "⢸"
                                    "⣸"
                                    "⢼"
                                    "⢺"
                                    "⢹"
                                    "⣹"
                                    "⢽"
                                    "⢻"
                                    "⣻"
                                    "⢿"
                                    "⣿"]
                          :generating [["▖" "▘" "▝" "▗"]]
                          :thinking ["▁"
                                     "▂"
                                     "▃"
                                     "▄"
                                     "▅"
                                     "▆"
                                     "▇"
                                     "█"]}
                :input {:prefix " " :height 8}
                :edit {:border :single :start_insert true}
                :ask {:floating true
                      :border :single
                      :start_insert true
                      :focus_on_apply :ours}})

(local diff {:autojump true :override_timeoutlen 1000})

(local repo_map {:ignore_patterns ["%.git"
                                   "%.worktree"
                                   :__pycache__
                                   :node_modules
                                   :result]
                 :negate_patterns []})

(local selector {:provider :telescope})

; MCP
(local hub (require :mcphub))
(local hub_ext (require :mcphub.extensions.avante))
(hub.setup {:extensions {:avante {:make_slash_commands true}}})

(local system_prompt (fn []
                       (or (-?> (hub.get_hub_instance)
                                (: :get_active_servers_prompt))
                           "")))

(local custom_tools (fn [] [(hub_ext.mcp_tool)]))

; ACP
(local acp_providers
       {; npm install -g @zed-industries/claude-code-acp
        :claude-code {:command :claude-code-acp
                      :args []
                      :env {:NODE_NO_WARNINGS :1
                            ;; use api
                            ; :ANTHROPIC_API_KEY (os.getenv :ANTHROPIC_API_KEY)
                            ;; use claude cli to setup token e.g. `claude setup-token`
                            :CLAUDE_CODE_OAUTH_TOKEN (os.getenv :CLAUDE_CODE_OAUTH_TOKEN)}}})

; RAG
(local rag_service {:enabled false
                    :host_mount (os.getenv :HOME)
                    :runner :nix
                    :llm {:provider :ollama
                          :endpoint "http://localhost:11434"
                          :api_key ""
                          :model "gpt-oss:20b"
                          :extra nil}
                    :embed {:provider :ollama
                            :endpoint "https://api.openai.com/v1"
                            :api_key ""
                            :model "gpt-oss:20b"
                            :extra nil}
                    :docker_extra_args ""})

(local history
       {:max_tokens 8192
        :carried_entry_count nil
        :storage_path (.. (vim.fn.stdpath :state) :/avante)
        :paste {:extension :png :filename "pasted-%Y%m%d%H%M%S"}})

(local highlights {:diff {:current :DiffText :incoming :DiffAdd}})

(local img_paste {:url_encode_path true :template "\nimage: $FILE_PATH\n"})

(local hints {:enabled false})

(local input {:provider :snacks :provider_opts {}})

(local slash_commands [])

(avante.setup {:provider :claude-code
               :mode :agentic
               :auto_suggestions_provider :ollama
               : behaviour
               : mappings
               : rag_service
               :tokenizer :tiktoken
               :disabled_tools [:web_search
                                :list_files
                                :search_files
                                :read_file
                                :create_file
                                :rename_file
                                :delete_file
                                :create_dir
                                :rename_dir
                                :delete_dir
                                :bash]
               : system_prompt
               : custom_tools
               : acp_providers
               : history
               : highlights
               : img_paste
               : windows
               : diff
               : hints
               : selector
               : input
               : repo_map
               : slash_commands})

(let [blink (require :blink.cmp)]
  (blink.add_source_provider :avante
                             {:module :blink-cmp-avante
                              :name :Avante
                              :opts {}
                              :enabled #(vim.tbl_contains [:AvanteInput]
                                                          vim.bo.filetype)})
  (blink.add_filetype_source :AvanteInput :avante))
