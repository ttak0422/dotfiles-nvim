;; Register completion before toggler's lazy configuration replaces this command.
(when (= (vim.fn.exists ":Terminal") 0)
  (vim.api.nvim_create_user_command :Terminal
    (fn [opts]
      (require :toggler)
      (vim.api.nvim_cmd {:cmd :Terminal :args opts.fargs :count opts.count} {}))
    {:nargs :* :count 0
     :complete (fn [_ line pos]
                 (vim.fn.getcompletion (string.gsub (string.sub line 1 pos)
                                                     "^.-Terminal%s*" "")
                                       :shellcmdline))
     :desc "Open a terminal slot; command arguments apply only on first creation"}))
