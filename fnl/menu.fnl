(let [menu (require :menu)
      opts {}
      separator {:name :separator}
      default [{:name "Copy all content" :cmd "%y+"}
                    separator
                    {:name " Edit local config" :cmd :ConfigLocalEdit}]]
  (vim.api.nvim_create_user_command :OpenMenu
                                    (fn [] (menu.open default opts)) {}))
