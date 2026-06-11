(local worktab (require :worktab))

;; 名前付きで新しいタブを開く: `:Tabnew foo`。無名なら `:Tabnew`。
(vim.api.nvim_create_user_command :Tabnew
                                  (fn [opts]
                                    (vim.cmd.tabnew)
                                    (when (not= opts.args "")
                                      (worktab.set_name opts.args)))
                                  {:nargs "?"
                                   :desc "Open a new tab with an optional name"})
