(local avante (require :avante))
(local avante_lib (require :avante_lib))

; MCP
(local hub (require :mcphub))
(local hub_ext (require :mcphub.extensions.avante))
(local system_prompt (fn []
                       (or (-?> (hub.get_hub_instance)
                                (: :get_active_servers_prompt))
                           "")))

(local custom_tools (fn [] [(hub_ext.mcp_tool)]))

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
                  :auto_approve_tool_permissions [:rag_search
                                                  :python
                                                  :git_diff
                                                  ;:git_commit
                                                  :glob
                                                  :search_keyword
                                                  :read_file_toplevel_symbols
                                                  :read_file
                                                  :create_file
                                                  :move_path
                                                  :copy_path
                                                  ;:delete_path
                                                  :create_dir
                                                  :bash
                                                  :web_search
                                                  :fetch]})

(local history
       {:max_tokens 8192
        :carried_entry_count nil
        :storage_path (.. (vim.fn.stdpath :state) :/avante)
        :paste {:extension :png :filename "pasted-%Y%m%d%H%M%S"}})

(local highlights {:diff {:current :DiffText :incoming :DiffAdd}})

(local img_paste {:url_encode_path true :template "\nimage: $FILE_PATH\n"})

(local mappings {:diff {:ours :co
                        :theirs :ct
                        :all_theirs :ca
                        :both :cb
                        :cursor :cc
                        :next "]x"
                        :prev "[x"}
                 :suggestion {:accept :<C-a>
                              :next "<M-]>"
                              :prev "<M-[>"
                              :dismiss :<M-e>}
                 :jump {:next "]]" :prev "[["}
                 :submit {:normal :<CR> :insert :<C-s>}
                 :cancel {:normal [:<C-c> :<Esc> :q] :insert [:<C-c>]}
                 :ask :<leader>aa
                 :new_ask :<leader>an
                 :edit :<leader>ae
                 :refresh :<leader>ar
                 :focus :<leader>af
                 :stop :<leader>aS
                 :toggle {:default :<leader>at
                          :debug :<leader>ad
                          :hint :<leader>ah
                          :suggestion :<leader>as
                          :repomap :<leader>aR}
                 :sidebar {:apply_all :A
                           :apply_cursor :a
                           :retry_user_request :r
                           :edit_user_request :e
                           :switch_windows :<Tab>
                           :reverse_switch_windows :<S-Tab>
                           :remove_file :d
                           :add_file "@"
                           :close [:q]
                           :close_from_input {:normal :q}}
                 :files {:add_current :<leader>ab :add_all_buffers :<leader>aB}
                 :select_model :<leader>a?
                 :select_history :<leader>ah})

(local windows {:position :right
                :fillchars "eob: "
                :wrap true
                :width 50
                :height 50
                :sidebar_header {:enabled false :align :center :rounded false}
                :input {:prefix " " :height 8}
                :edit {:border {" " " " " " " " " " " " " " " "}
                       :start_insert true}
                :ask {:floating false
                      :border {" " " " " " " " " " " " " " " "}
                      :start_insert true
                      :focus_on_apply :ours}})

(local diff {:autojump true :override_timeoutlen 1000})

(local hints {:enabled false})

(local repo_map {:ignore_patterns ["%.git"
                                   "%.worktree"
                                   :__pycache__
                                   :node_modules
                                   :result]
                 :negate_patterns []})

(avante_lib.load)
(avante.setup {:mode :agentic
               :provider :sonet4
               :providers {:sonet4 {:__inherited_from :claude
                                    :model :claude-sonnet-4-0}
                           :opus4 {:__inherited_from :claude
                                   :model :claude-opus-4-0
                                   :extra_request_body {:max_tokens 32000}}}
               :tokenizer :tiktoken
               :disabled_tools [:web_search]
               : system_prompt
               : custom_tools
               : behaviour
               : history
               : highlights
               : img_paste
               : mappings
               : windows
               : diff
               : hints
               : repo_map})

;; vim.env.ANTHROPIC_API_KEY=...
(pcall dofile (.. vim.env.HOME :/.config/nvim/avante.lua))
