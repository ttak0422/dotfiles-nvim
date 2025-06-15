(local menu (require :menu))

(local separator {:name :separator})

(local default
       [{:name "Copy all content" :cmd "%y+"}
        {:name " Edit local config" :cmd :ConfigLocalEdit}
        separator
        {:name "󰄉 Timer" :cmd #(vim.cmd :TimerlyToggle)}
        {:name " Show keys" :cmd #(vim.cmd :ShowkeysToggle)}
        {:name " Color Picker" :cmd #(vim.cmd :Huefy)}])

(vim.api.nvim_create_user_command :OpenMenu #(menu.open default {}) {})
