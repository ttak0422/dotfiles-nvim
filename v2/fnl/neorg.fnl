(local neorg (require :neorg))

(let [metagen {:type :auto :undojoin_updates true}
      journal {:journal_folder :journal :strategy :flat}
      keybinds {:default_keybinds false}
      completion {:engine {:module_name :external.lsp-completion}}
      interim-ls {:completion_provider {:enable true
                                        :documentation true
                                        :categories false}}
      concealer {:icons {:code_block {:conceal false}
                         :heading {:icons ["󰼏"
                                           "󰎨"
                                           "󰼑"
                                           "󰎲"
                                           "󰼓"
                                           "󰎴"]}
                         :todo {:done {:icon ""}
                                :pending {:icon "󰞌"}
                                :undone {:icon ""}
                                :uncertain {:icon "?"}
                                :on_hold {:icon ""}
                                :cancelled {:icon ""}
                                :recurring {:icon ""}
                                :urgent {:icon ""}}}}
      dirman {:workspaces {:default "~/neorg"} :default_workspace :default}
      markdown {:extensions :all}
      load {;; default modules
            :core.defaults {:config {:disable []}}
            :core.esupports.metagen {:config metagen}
            :core.journal {:config journal}
            :core.keybinds {:config keybinds}
            ;; other modules
            :core.completion {:config completion}
            :core.concealer {:config concealer}
            :core.dirman {:config dirman}
            :core.export.markdown {:config markdown}
            ;; external
            :external.interim-ls {:config interim-ls}
            :external.conceal-wrap {}}]
  (neorg.setup {: load}))

(let [dirman (neorg.modules.get_module :core.dirman)
      path (require :plenary.path)
      git_dir? #(-> (path:new (.. (vim.fn.getcwd) :/.git))
                    (: :exists))
      get_dir #(vim.fn.fnamemodify (vim.fn.getcwd) ":t")
      get_branch #(let [out (vim.fn.system "git rev-parse --abbrev-ref HEAD")]
                    (if (= vim.v.shell_error 0)
                        (out:gsub "%s+" "")
                        (error "branch not found")))
      create_file (fn [path]
                    (dirman.create_file path nil {}))
      dated_title (fn [title]
                    (-> title
                        (string.gsub " " "_")
                        ((fn [t]
                           (.. (os.date "%Y%m%d%H%M%S") "_" t)))))
      scratch_path (fn [path] (.. :scratch/ path))
      commands {:NeorgFuzzySearch "Telescope neorg find_norg_files"
                :NeorgScratch #(case (vim.fn.input " Title: ")
                                 (where title (not= title "")) (-> title
                                                                   (dated_title)
                                                                   (scratch_path)
                                                                   (create_file)))
                :NeorgGit #(if (git_dir?)
                               (create_file (.. :project/ (get_dir) :/main))
                               (vim.notify "Not a git repository" :warn))
                :NeorgGitBranch #(if (git_dir?)
                                     (create_file (.. :project/ (get_dir) "/"
                                                      (get_branch)))
                                     (vim.notify "Not a git repository" :warn))}]
  (each [name fun (pairs commands)]
    (vim.api.nvim_create_user_command name fun {})))
