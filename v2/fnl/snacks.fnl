(local snacks (require :snacks))

(local header (table.concat ["                                                                    "
                             "      ████ ██████           █████      ██                     "
                             "     ███████████             █████                             "
                             "     █████████ ███████████████████ ███   ███████████   "
                             "    █████████  ███    █████████████ █████ ██████████████   "
                             "   █████████ ██████████ █████████ █████ █████ ████ █████   "
                             " ███████████ ███    ███ █████████ █████ █████ ████ █████  "
                             "██████  █████████████████████ ████ █████ █████ ████ ██████ "]
                            "\n"))

(local dashboard
       {:width 60
        :pane_gap 1
        :preset {:keys [{:icon " "
                         :key :f
                         :desc "Find File"
                         :action ":lua Snacks.dashboard.pick('files')"}
                        {:icon " "
                         :key :n
                         :desc "New File"
                         :action ":ene | startinsert"}
                        {:icon " "
                         :key :g
                         :desc "Find Text"
                         :action ":lua Snacks.dashboard.pick('live_grep')"}
                        {:icon " "
                         :key :r
                         :desc "Recent Files"
                         :action ":lua Snacks.dashboard.pick('oldfiles')"}
                        {:icon "󰦛 "
                         :key :s
                         :desc "Restore Session"
                         :section :session}
                        {:icon " " :key :q :desc :Quit :action ":qa"}]
                 : header}
        :sections [{:section :header} {:section :keys :gap 1 :padding 1}]})

(local bigfile {:notify true
                ;; 1MB
                :size (* 1 1024 1024)
                :line_length 2000})

(snacks.setup {: dashboard : bigfile})
