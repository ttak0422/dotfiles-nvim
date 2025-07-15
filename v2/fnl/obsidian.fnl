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

(local daily_notes {:folder :journal
                    :date_format "%Y-%m-%d"
                    :default_tags [:journal]
                    :template nil})

(local completion {:nvim_cmp false :blink true :min_chars 2 :create_new true})

(local ui {:ignore_conceal_warn true})

(obsidian.setup {: workspaces
                 : daily_notes
                 : completion
                 : ui
                 :footer {:enabled false}
                 :log_level vim.log.levels.WARN})
