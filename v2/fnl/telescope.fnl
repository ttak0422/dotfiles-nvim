(local telescope (require :telescope))
(local builtin (require :telescope.builtin))
(local themes (require :telescope.themes))
(local actions (require :telescope.actions))
(local lga_actions (require :telescope-live-grep-args.actions))

(local defaults
       (themes.get_ivy {:path_display [:truncate]
                        :prompt_prefix " "
                        :selection_caret " "
                        ;; skkeleton is loaded on InsertEnter
                        :mappings {:i {:<C-j> {1 "<Plug>(skkeleton-enable)"
                                               :type :command}
                                       :<Down> actions.cycle_history_next
                                       :<Up> actions.cycle_history_prev}
                                   :n {:<Down> actions.cycle_history_next
                                       :<Up> actions.cycle_history_prev}}}))

(local extensions
       {:live_grep_args {:auto_quoting true
                         :mappings {:i {:<C-t> (lga_actions.quote_prompt {:postfix " -t "})
                                        :<C-i> (lga_actions.quote_prompt {:postfix " --iglob "})}}}})

(telescope.setup {: defaults : extensions})
(telescope.load_extension :live_grep_args)
(telescope.load_extension :sonictemplate)
(telescope.load_extension :projects)
(telescope.load_extension :mr)
(vim.api.nvim_create_user_command :TelescopeBuffer
                                  #(builtin.buffers {:sort_mru true
                                                     :ignore_current_buffer true})
                                  {})
