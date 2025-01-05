(let [menu (require :menu)
      opts {}
      separator {:name :separator}
      default [{:name "Copy all content" :cmd "%y+"}
               {:name " Edit local config" :cmd :ConfigLocalEdit}
               separator
               {:name "󰄉 Timer" :cmd (fn [] (vim.cmd :TimerlyToggle))}
               {:name " Color Picker" :cmd (fn [] (vim.cmd :Huefy))}]]
  (vim.api.nvim_create_user_command :OpenMenu (fn [] (menu.open default opts))
                                    {}))
