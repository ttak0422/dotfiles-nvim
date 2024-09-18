(let [errorHl (vim.api.nvim_get_hl_by_name "@comment.error" true)
      noteHl (vim.api.nvim_get_hl_by_name "@comment.note" true)]
  (each [hl spec (pairs {:MarkAmbiguous {:fg errorHl.background}
                         :MarkHold {:fg noteHl.background}})]
    (vim.api.nvim_set_hl 0 hl spec)))

(let [neorg (require :neorg) ; completion {:engine :nvim-cmp}
      defaults {:disable []}
      dirman {:workspaces {:notes "~/neorg"
                           ;; WIP
                           :dotfiles "~/ghq/github.com/ttak0422/Limbo/notes"}
              :default_workspace :notes}
      highlights {:highlights {:todo_items {:on_hold :+MarkHold
                                            :urgent :+MarkAmbiguous}}}
      keybinds {:default_keybinds false}
      concealer {:icons {:code_block {:conceal false}
                         :heading {:icons ["󰼏"
                                           "󰎨"
                                           "󰼑"
                                           "󰎲"
                                           "󰼓"
                                           "󰎴"]}
                         :todo {:done {:icon ""}
                                :pending {:icon ""}
                                :undone {:icon ""}
                                :uncertain {:icon "?"}
                                :on_hold {:icon ""}
                                :cancelled {:icon ""}
                                :recurring {:icon ""}
                                :urgent {:icon ""}}}}
      journal {:journal_folder :journal :strategy :nested}
      metagen {:type :auto}
      ; templates {:templates_dir [] :default_subcommand :fload}
      load {:core.autocommands {}
            ; :core.completion {:config completion}
            :core.defaults {:config defaults}
            :core.dirman {:config dirman}
            :core.highlights {:config highlights}
            ; :core.integrations.nvim-cmp {}
            :core.integrations.treesitter {}
            :core.keybinds {:config keybinds}
            :core.storage {}
            :core.summary {}
            :core.ui {}
            :core.journal {:config journal}
            :core.esupports.metagen {:config metagen}
            :core.concealer {:config concealer}
            :core.tempus {}
            :core.ui.calendar {}
            :core.integrations.telescope {}
            ;; WIP
            :external.jupyter {}
            ; :external.templates {:config templates}
            } ; cmp (require :cmp)
      ; sources (cmp.config.sources [{:name :neorg}] [{:name :buffer}])
      ]
  (neorg.setup {: load}))

(vim.api.nvim_create_user_command :NeorgFuzzySearch
                                  "Telescope neorg find_linkable" {})
