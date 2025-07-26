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
                                      #(if (api.cursor_on_markdown_link nil nil
                                                                        true)
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
