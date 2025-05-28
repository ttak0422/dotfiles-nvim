(local autoclose (require :autoclose))

(local keys {"(" {:escape false :close true :pair "()"}
             "[" {:escape false :close true :pair "[]"}
             "{" {:escape false :close true :pair "{}"}
             :> {:escape true :close false :pair "<>"}
             ")" {:escape true :close false :pair "()"}
             "]" {:escape true :close false :pair "[]"}
             "}" {:escape true :close false :pair "{}"}
             "\"" {:escape true :close true :pair "\"\""}
             "'" {:escape true :close true :pair "''"}
             "`" {:escape true :close true :pair "``"}})

(local options {:disabled_filetypes [:text
                                     :spectre_panel
                                     :norg
                                     :TelescopePrompt]
                :disable_when_touch false
                :touch_regex "[%w(%[{]"
                :pair_spaces false
                :auto_indent true
                :disable_command_mode true})

(autoclose.setup {: keys : options})
