(local menu (require :menu))

(local separator {:name :separator})

(local default
       [{:hl :Normal :name " Toggle NoNeckPain" :cmd :NoNeckPain}
        {:hl :Normal :name " Toggle colorize" :cmd :ColorizerToggle}
        {:hl :Normal :name " Edit local config" :cmd :ConfigLocalEdit}
        {:hl :Normal :name "󰞷 Open scratch buffer" :cmd :RepluaOpen}
        separator
        {:hl :Normal :name "󰄉 Timer" :cmd #(vim.cmd :TimerlyToggle)}
        {:hl :Normal :name " Show keys" :cmd #(vim.cmd :ShowkeysToggle)}
        {:hl :Normal :name " Color Picker" :cmd #(vim.cmd :Huefy)}])

(vim.api.nvim_create_user_command :OpenMenu #(menu.open default {:border true})
                                  {})
