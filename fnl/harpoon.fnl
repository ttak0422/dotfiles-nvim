(let [M (require :harpoon)
      settings {:save_on_toggle false
                :sync_on_ui_close false
                :key (fn []
                       (vim.loop.cwd))}]
  (M:setup {: settings}))
