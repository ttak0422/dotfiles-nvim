(let [M (require :neogit)
      signs {:hunk ["" ""] :item ["" ""] :section ["" ""]}
      integrations {:telescope true :diffview true :fzf_lua nil}
      mappings {:commit_editor {:q :Close
                                :<c-c><c-c> :Submit
                                :<c-c><c-k> :Abort
                                :<m-p> :PrevMessage
                                :<m-n> :NextMessage
                                :<m-r> :ResetMessage}
                :commit_editor_I {:<c-c><c-c> :Submit :<c-c><c-k> :Abort}
                :rebase_editor {:p :Pick
                                :r :Reword
                                :e :Edit
                                :s :Squash
                                :f :Fixup
                                :x :Execute
                                :d :Drop
                                :b :Break
                                :q :Close
                                :<cr> :OpenCommit
                                :gk :MoveUp
                                :gj :MoveDown
                                :<c-c><c-c> :Submit
                                :<c-c><c-k> :Abort
                                "[c" :OpenOrScrollUp
                                "]c" :OpenOrScrollDown}
                :rebase_editor_I {:<c-c><c-c> :Submit :<c-c><c-k> :Abort}
                :finder {:<cr> :Select
                         :<c-c> :Close
                         :<esc> :Close
                         :<c-n> :Next
                         :<c-p> :Previous
                         :<down> :Next
                         :<up> :Previous
                         :<tab> :MultiselectToggleNext
                         :<s-tab> :MultiselectTogglePrevious
                         :<c-j> :NOP
                         :<ScrollWheelDown> :ScrollWheelDown
                         :<ScrollWheelUp> :ScrollWheelUp
                         :<ScrollWheelLeft> :NOP
                         :<ScrollWheelRight> :NOP
                         :<LeftMouse> :MouseClick
                         :<2-LeftMouse> :NOP}
                :popup {:g? :HelpPopup
                        :A :CherryPickPopup
                        :d :DiffPopup
                        :M :RemotePopup
                        :P :PushPopup
                        :X :ResetPopup
                        :Z :StashPopup
                        :i :IgnorePopup
                        :t :TagPopup
                        :b :BranchPopup
                        :B :BisectPopup
                        :w :WorktreePopup
                        :c :CommitPopup
                        :f :FetchPopup
                        :L :LogPopup
                        :m :MergePopup
                        :p :PullPopup
                        :r :RebasePopup
                        :R :RevertPopup}
                :status {:j :MoveDown
                         :k :MoveUp
                         :o :OpenTree
                         :q :Close
                         :I :InitRepo
                         :1 :Depth1
                         :2 :Depth2
                         :3 :Depth3
                         :4 :Depth4
                         :<tab> :Toggle
                         :x :Discard
                         :s :Stage
                         :S :StageUnstaged
                         :<c-s> :StageAll
                         :u :Unstage
                         :K :Untrack
                         :U :UnstageStaged
                         :y :ShowRefs
                         :$ :CommandHistory
                         :Y :YankSelected
                         :<c-r> :RefreshBuffer
                         :<cr> :GoToFile
                         :<c-v> :VSplitOpen
                         :<c-x> :SplitOpen
                         :<c-t> :TabOpen
                         "{" :GoToPreviousHunkHeader
                         "}" :GoToNextHunkHeader
                         "[c" :OpenOrScrollUp
                         "]c" :OpenOrScrollDown}}]
  (M.setup {:use_default_keymaps false
            :disable_hint false
            :disable_context_highlighting false
            :disable_signs false
            :graph_style :unicode
            :console_timeout 10000
            : mappings
            : signs
            : integrations}))
