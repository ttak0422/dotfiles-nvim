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

(local workspaces [{:name :default :path default_vault}])

(local daily_notes {:folder :notes/journal
                    :date_format "%Y-%m-%d"
                    :alias_format "%B %-d %Y"
                    :default_tags [:journal]
                    :template nil})

(local completion {:nvim_cmp false :blink true :min_chars 2 :create_new true})

(obsidian.setup {: workspaces
                 : daily_notes
                 : completion
                 :notes_subdir :notes
                 :log_level vim.log.levels.WARN})
