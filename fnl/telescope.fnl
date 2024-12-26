(let [M (require :telescope)
      builtin (require :telescope.builtin)
      themes (require :telescope.themes)
      actions (require :telescope.actions)
      lga_actions (require :telescope-live-grep-args.actions)
      defaults (themes.get_ivy {:path_display [:truncate]
                                :prompt_prefix " "
                                :selection_caret " "
                                ;; skkeleton is loaded on InsertEnter
                                :mappings {:i {:<C-j> {1 "<Plug>(skkeleton-enable)"
                                                       :type :command}
                                               :<Down> actions.cycle_history_next
                                               :<Up> actions.cycle_history_prev}
                                           :n {:<Down> actions.cycle_history_next
                                               :<Up> actions.cycle_history_prev}}})
      extensions {:live_grep_args {:auto_quoting true
                                   :mappings {:i {:<C-t> (lga_actions.quote_prompt {:postfix " -t "})
                                                  :<C-i> (lga_actions.quote_prompt {:postfix " --iglob "})}}}
                  :ast_grep {:command [:sg :--json=stream]
                             :grep_open_files false
                             :lang nil}}]
  (M.setup {: defaults : extensions})
  (M.load_extension :live_grep_args)
  (M.load_extension :ast_grep)
  (M.load_extension :sonictemplate)
  (vim.api.nvim_create_user_command :TelescopeBuffer
                                    (fn []
                                      (builtin.buffers {:sort_mru true
                                                        :ignore_current_buffer true}))
                                    {}))
