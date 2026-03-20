(local telescope (require :telescope))
(local builtin (require :telescope.builtin))
(local themes (require :telescope.themes))
(local actions (require :telescope.actions))
(local lga_actions (require :telescope-live-grep-args.actions))

(local defaults
       (themes.get_cursor {:path_display [:truncate]
                           :prompt_prefix " "
                           :selection_caret " "
                           ;; skkeleton is loaded on InsertEnter
                           :preview false
                           :layout_config {:width (fn [self _ _]
                                                    (let [winid self.original_win_id
                                                          win_width (vim.api.nvim_win_get_width winid)
                                                          cursor (vim.api.nvim_win_get_cursor winid)
                                                          col (. cursor 2)]
                                                      (math.max 80
                                                                (- win_width
                                                                   col 2))))
                                           :height (fn [self _ _]
                                                     (let [winid self.original_win_id
                                                           win_height (vim.api.nvim_win_get_height winid)
                                                           cursor (vim.api.nvim_win_get_cursor winid)
                                                           row (. cursor 1)]
                                                       (math.max 10
                                                                 (- win_height
                                                                    row 2))))}
                           :mappings {:i {:<C-j> {1 "<Plug>(skkeleton-enable)"
                                                  :type :command}
                                          :<Down> actions.cycle_history_next
                                          :<Up> actions.cycle_history_prev}
                                      :n {:<Down> actions.cycle_history_next
                                          :<Up> actions.cycle_history_prev}}}))

(local extensions
       {:live_grep_args {:auto_quoting true
                         :mappings {:i {:<C-t> (lga_actions.quote_prompt {:postfix " -t "})
                                        :<C-i> (lga_actions.quote_prompt {:postfix " --iglob "})}}
                         :additional_args #[:--hidden :--glob :!.git/**]}})

(telescope.setup {: defaults : extensions})

(telescope.load_extension :live_grep_args)
(telescope.load_extension :sonictemplate)
(telescope.load_extension :projects)
(telescope.load_extension :mr)
(telescope.load_extension :ghq)
(vim.api.nvim_create_user_command :TelescopeBuffer
                                  #(builtin.live_grep {:grep_open_files true})
                                  {})

(vim.api.nvim_create_user_command :TelescopeBufferName
                                  #(builtin.buffers {:sort_mru true
                                                     :ignore_current_buffer false})
                                  {})
