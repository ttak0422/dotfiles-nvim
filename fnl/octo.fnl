(let [github_hostname (or vim.g.github_hostname "")
      ui {:use_signcolumn false :use_signstatus true}
      file_panel {:size 10 :use_icons true}
      colors (let [c (require :morimo.colors)]
               {:white c.fg0
                :grey c.grey0
                :black c.bg0
                :red c.red
                :dark_red c.darkRed
                :green c.green
                :dark_green c.darkGreen
                :yellow c.yellow
                :dark_yellow c.darkYellow
                :blue c.blue
                :dark_blue c.darkBlue
                :purple c.purple})
      picker_config {:use_emojis false
                     :mappings {:open_in_browser {:lhs :<C-o>
                                                  :desc "open issue in browser"}
                                :copy_url {:lhs :<C-y>
                                           :desc "copy url to system clipboard"}
                                :checkout_pr {:lhs :<C-s>
                                              :desc "switch pull request"}
                                :merge_pr {:lhs :<C-m>
                                           :desc "merge pull request"}}}
      issues {:order_by {:field :CREATED_AT :direction :DESC}}
      reviews {:auto_show_threads true}
      pull_requests {:order_by {:field :CREATED_AT :direction :DESC}
                     :always_select_remote_on_create false}
      mappings_disable_default true
      mappings (let [m (fn [lhs desc] {: lhs : desc})
                     issue {:close_issue (m :<LocalLeader>ci "close issue")
                            :reopen_issue (m :<LocalLeader>oi "reopen issue")
                            :list_issues (m :<LocalLeader>li
                                            "list open issues on same repo")
                            :reload (m :<C-r> "reload isssue")
                            :open_in_browser (m :<C-o> "open issue in browser")
                            :copy_url (m :<C-y> "copy url to clipboard")
                            :goto_issue (m :<LocalLeader>gi
                                           "navigate to a local repo issue")
                            ;; assignee
                            :add_assignee (m :<LocalLeader>aa "add assignee")
                            :remove_assignee (m :<LocalLeader>ra
                                                "remove assignee")
                            ;; label
                            :create_label (m :<LocalLeader>cl "create label")
                            :add_label (m :<LocalLeader>al "add label")
                            :remove_label (m :<LocalLeader>rl "remove label")
                            ;; comment
                            :add_comment (m :<LocalLeader>ac "add comment")
                            :delete_comment (m :<LocalLeader>dc
                                               "delete comment")
                            :next_comment (m "]c" "go to next comment")
                            :prev_comment (m "[c" "go to previous comment")
                            ;; reaction
                            :react_hooray (m :<LocalLeader>tt
                                             "toggle :tada: reaction")
                            :react_heart (m :<LocalLeader>th
                                            "toggle :heart: reaction")
                            :react_eyes (m :<LocalLeader>te
                                           "toggle :eye: reaction")
                            :react_thumbs_up (m :<LocalLeader>t+
                                                "toggle :+1: reaction")
                            :react_thumbs_down (m :<LocalLeader>t-
                                                  "toggle :-1: reaction")
                            :react_rocket (m :<LocalLeader>tr
                                             "toggle :rocket: reaction")
                            :react_laugh (m :<LocalLeader>tl
                                            "toggle :laughing: reaction")
                            :react_confused (m :<LocalLeader>tc
                                               "toggle :confused: reaction")}
                     pull_request {:checkout_pr (m :<LocalLeader><CR>
                                                   "checkout PR")
                                   :close_issue (m :<LocalLeader>cp "close PR")
                                   :reopen_issue (m :<LocalLeader>op
                                                    "reopen PR")
                                   :list_issues (m :<LocalLeader>lp
                                                   "list open issues on same repo")
                                   :reload (m :<C-r> "reload PR")
                                   :open_in_browser (m :<C-o>
                                                       "open PR in browser")
                                   :merge_pr (m :<LocalLeader>mp "merge PR")
                                   :copy_url (m :<C-y> "copy url to clipboard")
                                   :goto_file (m :gf "go to file")
                                   :squash_and_merge_pr (m :<LocalLeader>msp
                                                           "merge PR (squash)")
                                   :rebase_and_merge_pr (m :<LocalLeader>mrp
                                                           "merge PR (rebase)")
                                   :list_commits (m :<LocalLeader>lc
                                                    "list PR commits")
                                   :list_changed_files (m :<LocalLeader>lf
                                                          "list PR changed files")
                                   :show_pr_diff (m :<LocalLeader>sd
                                                    "show PR diff")
                                   :goto_issue (m :<LocalLeader>gi
                                                  "navigate to local repo issue")
                                   ;; reviewer
                                   :add_reviewer (m :<LocalLeader>ar
                                                    "add reviewer")
                                   :remove_reviewer (m :LocalLeader>rr
                                                       "remove reviewer")
                                   ;; assignee
                                   :add_assignee (m :<LocalLeader>aa
                                                    "add assignee")
                                   :remove_assignee (m :<LocalLeader>ra
                                                       "remove assignee")
                                   ;; label
                                   :create_label (m :<LocalLeader>cl
                                                    "create label")
                                   :add_label (m :<LocalLeader>al "add label")
                                   :remove_label (m :<LocalLeader>rl
                                                    "remove label")
                                   ;; comment
                                   :add_comment (m :<LocalLeader>ac
                                                   "add comment")
                                   :delete_comment (m :<LocalLeader>dc
                                                      "delete comment")
                                   :next_comment (m "[c" "go to next comment")
                                   :prev_comment (m "]c"
                                                    "go to previous comment")
                                   ;; reaction
                                   :react_hooray (m :<LocalLeader>tt
                                                    "toggle :tada: reaction")
                                   :react_heart (m :<LocalLeader>th
                                                   "toggle :heart: reaction")
                                   :react_eyes (m :<LocalLeader>tw
                                                  "toggle :eye: reaction")
                                   :react_thumbs_up (m :<LocalLeader>t+
                                                       "toggle :+1: reaction")
                                   :react_thumbs_down (m :<LocalLeader>t-
                                                         "toggle :-1: reaction")
                                   :react_rocket (m :<LocalLeader>tr
                                                    "toggle :rocket: reaction")
                                   :react_laugh (m :<LocalLeader>tl
                                                   "toggle :laughing: reaction")
                                   :react_confused (m :<LocalLeader>tc
                                                      "toggle :confused: reaction")
                                   ;; review
                                   :review_start (m :<LocalLeader>sr
                                                    "start a review for the current PR")
                                   :review_resume (m :<LocalLeader>rr
                                                     "resume a pending review for the current PR")}
                     review_thread {:goto_issue (m :<LocalLeader>gi
                                                   "navigate to a local repo issue")
                                    :close_review_tab (m :<C-c>
                                                         "close review tab")
                                    ;; comment
                                    :add_comment (m :<LocalLeader>ac
                                                    "add comment")
                                    :delete_comment (m :<LocalLeader>dc
                                                       "delete comment")
                                    :next_comment (m "]c" "go to next comment")
                                    :prev_comment (m "[c"
                                                     "go to previous comment")
                                    :add_suggestion (m :<LocalLeader>as
                                                       "add suggestion")
                                    ;; entry
                                    :select_next_entry (m "]e"
                                                          "move to next entry")
                                    :select_prev_entry (m "[e"
                                                          "move to previous entry")
                                    :select_first_entry (m "]E"
                                                           "move to first entry")
                                    :select_last_entry (m "]E"
                                                          "move to last entry")
                                    ;; reaction
                                    :react_hooray (m :<LocalLeader>tt
                                                     "toggle :tada: reaction")
                                    :react_heart (m :<LocalLeader>th
                                                    "toggle :heart: reaction")
                                    :react_eyes (m :<LocalLeader>te
                                                   "toggle :eye: reaction")
                                    :react_thumbs_up (m :<LocalLeader>t+
                                                        "toggle :+1: reaction")
                                    :react_thumbs_down (m :<LocalLeader>t-
                                                          "toggle :-1: reaction")
                                    :react_rocket (m :<LocalLeader>tr
                                                     "toggle :rocket: reaction")
                                    :react_laugh (m :<LocalLeader>tl
                                                    "toggle :laughing: reaction")
                                    :react_confused (m :<LocalLeader>tc
                                                       "toggle :confused: reaction")}
                     submit_win {:approve_review (m :<LocalLeader>A
                                                    "approva review")
                                 :comment_review (m :<LocalLeader>C
                                                    "comment review")
                                 :request_changes (m :<LocalLeader>R
                                                     "request changes review")
                                 :close_review_tab (m :<C-c> "close review tab")}
                     review_diff {:submit_review (m :<LocalLeader>S
                                                    "submit review")
                                  :discard_review (m :<LocalLeader>X
                                                     "discard review")
                                  ;;
                                  :add_review_comment (m :<LocalLeader>ac
                                                         "add a new review comment")
                                  :add_review_suggestion (m :<LocalLeader>as
                                                            "add a new review suggestion")
                                  :focus_files (m :<LocalLeader>E
                                                  "move focus to changed file panel")
                                  :toggle_files (m :<LocalLeader>e
                                                   "toggle changed files panel")
                                  :next_thread (m "]t" "move to next thread")
                                  :prev_thread (m "[t"
                                                  "move to previous thread")
                                  :select_next_entry (m "]e"
                                                        "move to next entry")
                                  :select_prev_entry (m "[e"
                                                        "move to previous entry")
                                  :select_first_entry (m "]E"
                                                         "move to first entry")
                                  :select_last_entry (m "]E"
                                                        "move to last entry")
                                  :close_review_tab (m :<C-c>
                                                       "close review tab")
                                  :toggle_viewed (m :<LocalLeader><LocalLeader>
                                                    "toggle viewer viewed state")
                                  :goto_file (m :gf "go to file")}
                     file_panel {:submit_review (m :<LocalLeader>S
                                                   "submit review")
                                 :discard_review (m :<LocalLeader>X
                                                    "discard review")
                                 :next_entry (m :j "move to next entry")
                                 :prev_entry (m :k "move to previous entry")
                                 :select_entry (m :<CR>
                                                  "show selected changed file diffs")
                                 :refresh_files (m :<C-r>
                                                   "refresh changed files panel")
                                 :focus_files (m :<LocalLeader>E
                                                 "move focus to changed file panel")
                                 :toggle_files (m :<LocalLeader>e
                                                  "toggle changed files panel")
                                 :select_next_entry (m "]e"
                                                       "move to next entry")
                                 :select_prev_entry (m "[e"
                                                       "move to previous entry")
                                 :select_first_entry (m "]E"
                                                        "move to first entry")
                                 :select_last_entry (m "]E"
                                                       "move to last entry")
                                 :close_review_tab (m :<C-c> "close review tab")
                                 :toggle_viewed (m :<LocalLeader><LocalLeader>
                                                   "toggle viewer viewed state")}]
                 {: issue
                  : pull_request
                  : review_thread
                  : submit_win
                  : review_diff
                  : file_panel})]
  ((. (require :octo) :setup) {: github_hostname
                               : colors
                               : ui
                               : file_panel
                               : picker_config
                               : issues
                               : reviews
                               : pull_requests
                               : mappings_disable_default
                               : mappings
                               :use_local_fs false
                               :enable_builtin false
                               :default_remote [:upstream :origin]
                               :default_merge_method :commit
                               :ssh_aliases []
                               :picker :telescope
                               :users :search
                               :comment_icon "▊"
                               :outdated_icon "󰅒 "
                               :resolved_icon " "
                               :reaction_viewer_hint_icon " "
                               :user_icon " "
                               :timeline_marker " "
                               :timeline_indent :2
                               :right_bubble_delimiter "█"
                               :left_bubble_delimiter "█"
                               :snippet_context_lines 4
                               :gh_cmd :gh
                               :gh_env {}
                               :timeout 5000
                               :default_to_projects_v2 false}))
