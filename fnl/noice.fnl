(local excluded_filetypes (dofile args.exclude_ft_path))
(let [M (require :noice)
      U (require :noice.util)
      L (require :noice.lsp)
      cmdline (let [opts {:zindex 95}
                    format {:cmdline {:pattern "^:"
                                      :icon ""
                                      :lang :vim
                                      :title ""}
                            :search_down {:kind :search
                                          :pattern "^/"
                                          :icon " "
                                          :lang :regex
                                          :title ""}
                            :search_up {:kind :search
                                        :pattern "^%?"
                                        :icon " "
                                        :lang :regex
                                        :title ""}
                            :filter {:pattern "^:%s*!"
                                     :icon "$"
                                     :lang :bash
                                     :title ""}
                            :lua {:pattern "^:%s*lua%s+"
                                  :icon ""
                                  :lang :lua
                                  :title ""}
                            :help {:pattern "^:%s*he?l?p?%s+"
                                   :icon "?"
                                   :title ""}
                            :input {}}]
                {:enabled true : opts : format})
      messages {:enabled true
                :view :notify
                :view_error :notify
                :view_warn :notify
                :view_history :messages
                :view_search :virtualtext}
      popupmenu {:enabled true :backend :nui}
      redirect {:view :popup :filter {:event :msg_show}}
      commands (let [history {:view :split
                              :opts {:enter true :format :details}
                              :filter {:any [{:event :notify}
                                             {:error true}
                                             {:warning true}
                                             {:event :msg_show :kind [""]}
                                             {:event :lsp :kind :message}]}}
                     last {:view :popup
                           :opts {:enter true :format :details}
                           :filter {:any [{:event :notify}
                                          {:error true}
                                          {:warning true}
                                          {:event :msg_show :kind [""]}
                                          {:event :lsp :kind :message}]}
                           :filter_opts {:count 1}}
                     errors {:view :popup
                             :opts {:enter true :format :details}
                             :filter {:error true}
                             :filter_opts {:reverse true}}]
                 {: history : last : errors})
      notify {:enabled true :view :notify}
      lsp (let [progress {:enabled false}
                override {:vim.lsp.util.convert_input_to_markdown_lines false
                          :vim.lsp.util.stylize_markdown false}
                hover {:enabled false}
                signature {:enabled false}
                message {:enabled false}
                documentation {:view :hover
                               :opts {:lang :markdown
                                      :replace false
                                      :render :plain
                                      :format ["{message}"]
                                      :win_options {:concealcursor :n
                                                    :conceallevel 3}}}]
            {: progress
             : override
             : hover
             : signature
             : message
             : documentation})
      markdown {:hover ["|(%S-)|" vim.cmd.help "%[.-%]%((%S-)%)" U.open]
                :highlights ["|%S-|"
                             "@text.reference"
                             "@%S+"
                             "@parameter"
                             "^%s*(Parameters:)"
                             "@text.title"
                             "^%s*(Return:)"
                             "@text.title"
                             "^%s*(See also:)"
                             "@text.title"
                             "{%S-}"
                             "@parameter"]}
      health {:checker true}
      smart_move {: excluded_filetypes}
      presets {:bottom_search false
               :command_palette false
               :long_message_to_split true
               :inc_rename false
               :lsp_doc_border true}
      throttle (/ 1000 30)
      views (let [border :none
                  cmdline_popup {:border {:style border :padding [1 2]}
                                 :filter_options {}
                                 :win_options {:winhighlight "NormalFloat,NormalFloat,FloatBorder,FloatBorder"}
                                 :relative :editor
                                 :position {:row "50%" :col "50%"}}
                  hover {:border {:style border}}]
              {: cmdline_popup : hover})
      routes [{:filter {:event :msg_show
                        :any [{:find :^prompt$}
                              {:find "%d+L %d+B"}
                              {:find "; after #%d+"}
                              {:find "; before #%d+"}
                              {:find "%d fewer lines"}
                              {:find "%d more lines"}]}
               :opts {:skip true}}]]
  (M.setup {: cmdline
            : messages
            : popupmenu
            : redirect
            : commands
            : notify
            : lsp
            : markdown
            : health
            : smart_move
            : presets
            : throttle
            : views
            : routes}))
