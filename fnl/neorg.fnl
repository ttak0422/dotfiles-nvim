(let [errorHl (vim.api.nvim_get_hl_by_name "@comment.error" true)
      noteHl (vim.api.nvim_get_hl_by_name "@comment.note" true)]
  (each [hl spec (pairs {:MarkAmbiguous {:fg errorHl.background}
                         :MarkHold {:fg noteHl.background}})]
    (vim.api.nvim_set_hl 0 hl spec)))

(let [neorg (require :neorg) ; completion {:engine :nvim-cmp}
      defaults {:disable []}
      markdown {:extensions :all}
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
      journal {:journal_folder :journal :strategy :flat}
      metagen {:type :auto :undojoin_updates true}
      ; templates {:templates_dir [] :default_subcommand :fload}
      load {:core.autocommands {}
            ; :core.completion {:config completion}
            :core.defaults {:config defaults}
            :core.export {}
            :core.export.markdown {:config markdown}
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

;; user commands
(let [neorg (require :neorg)
      path (require :plenary.path)
      dirman (neorg.modules.get_module :core.dirman)
      create_command vim.api.nvim_create_user_command
      check_git_dir (fn []
                      (let [git_dir (path:new (.. (vim.fn.getcwd) :/.git))]
                        (git_dir:exists)))
      get_dir (fn []
                (vim.fn.fnamemodify (vim.fn.getcwd) ":t"))
      ;; sync
      get_branch (fn []
                   (let [out (vim.fn.system "git rev-parse --abbrev-ref HEAD")]
                     (if (= vim.v.shell_error 0)
                         (out:gsub "%s+" "")
                         (error "branch not found"))))
      create_file (fn [path]
                    (dirman.create_file path nil {}))]
  (create_command :NeorgFuzzySearch "Telescope neorg find_norg_files" {})
  (create_command :NeorgUID
                  (fn []
                    (case (vim.fn.input " Title: ")
                      (where title (not= title "")) (create_file (.. :uid/
                                                                     (-> title
                                                                         (string.gsub " "
                                                                                      "_")
                                                                         ((fn [t]
                                                                            (.. (os.date "%Y%m%d%H%M%S")
                                                                                "_"
                                                                                t))))))))
                  {})
  (create_command :NeorgGit
                  (fn []
                    (if (check_git_dir)
                        (create_file (.. :project/ (get_dir) :/main))
                        (vim.notify "Not a git repository" :warn)))
                  {})
  (create_command :NeorgGitBranch
                  (fn []
                    (if (check_git_dir)
                        (create_file (.. :project/ (get_dir) "/" (get_branch)))
                        (vim.notify "Not a git repository" :warn)))
                  {}))
