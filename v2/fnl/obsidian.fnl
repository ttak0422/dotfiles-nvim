(fn dir? [path]
  (-?> (vim.uv.fs_stat path)
       (. type)
       (= :directory)))

(local default_vault (vim.fn.fnamemodify (.. (os.getenv :HOME)
                                             :/vaults/default/)
                                         ":p:h"))

(if (not (dir? default_vault))
    (vim.fn.mkdir default_vault :p))

(local obsidian (require :obsidian))
(local api (require :obsidian.api))
(local path (require :obsidian.path))
(local note (require :obsidian.note))

(local workspaces [{:name :default :path default_vault}])

(local daily_notes {:folder :journal
                    :date_format "%Y-%m-%d"
                    :default_tags [:journal]
                    :template nil})

(local completion {:nvim_cmp false :blink true :min_chars 1 :create_new true})

(local ui {:ignore_conceal_warn true})

(local callbacks ; overwrite smart_action
       {:enter_note (fn [_ _note]
                      (vim.keymap.set :n :<CR>
                                      #(if (api.cursor_link nil nil true)
                                           (vim.cmd "Obsidian follow_link")
                                           (if (api.cursor_tag)
                                               (vim.cmd "Obsidian tags")))
                                      {:expr true
                                       :buffer true
                                       :desc "Obsidian Smart Action"}))})

(obsidian.setup {: workspaces
                 : daily_notes
                 : completion
                 : ui
                 : callbacks
                 :legacy_commands false
                 :statusline {:enabled false}
                 :footer {:enabled false}
                 :log_level vim.log.levels.WARN})

(let [dir (. (. _G :Obsidian) :dir)
      opts (. (. _G :Obsidian) :opts)
      get_branch #(let [out (: (vim.system [:git
                                            :rev-parse
                                            :--abbrev-ref
                                            :HEAD])
                               :wait)]
                    (if (= (. out :code) 0)
                        (: (. out :stdout) :gsub "%s+" "")
                        (error "branch not found")))
      open_note (fn [p aliases tags]
                  (: (if (p:exists)
                         (note.from_file p opts.load)
                         (: (note.create {:id p.stem
                                          : aliases
                                          : tags
                                          :dir (p:parent)})
                            :write {:template nil})) :open))
      ObsidianScratch #(open_note (/ (path:new dir) :scratch.md) [] [])
      ObsidianGitBranch #(let [branch (get_branch)]
                           (open_note (path:new (/ dir
                                                   (vim.fs.relpath (vim.fn.expand "~")
                                                                   (vim.fn.getcwd))
                                                   branch))
                                      []
                                      [(vim.fn.fnamemodify (vim.fn.getcwd) ":t")
                                       branch]))]
  (each [lhs rhs (pairs {: ObsidianScratch : ObsidianGitBranch})]
    (vim.api.nvim_create_user_command lhs rhs {})))
