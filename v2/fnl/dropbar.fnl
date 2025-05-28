(local dropbar (require :dropbar))
(local utils (require :dropbar.utils))
(local sources (require :dropbar.sources))

(local icons {:ui {:bar {:separator " " :extends "…"}
                   :menu {:separator " " :indicator " "}}
              :kinds {:symbols {:Array ""
                                :BlockMappingPair ""
                                :Boolean ""
                                :BreakStatement ""
                                :Call ""
                                :CaseStatement ""
                                :Class ""
                                :Color ""
                                :Constant ""
                                :Constructor ""
                                :ContinueStatement ""
                                :Copilot ""
                                :Declaration ""
                                :Delete ""
                                :DoStatement ""
                                :Element ""
                                :Enum ""
                                :EnumMember ""
                                :Event ""
                                :Field ""
                                :File ""
                                :Folder ""
                                :ForStatement ""
                                :Function ""
                                :GotoStatement ""
                                :Identifier ""
                                :IfStatement ""
                                :Interface ""
                                :Keyword ""
                                :List ""
                                :Log ""
                                :Lsp ""
                                :Macro ""
                                :MarkdownH1 "󰉫 "
                                :MarkdownH2 "󰉬 "
                                :MarkdownH3 "󰉭 "
                                :MarkdownH4 "󰉮 "
                                :MarkdownH5 "󰉯 "
                                :MarkdownH6 "󰉰 "
                                :Method ""
                                :Module ""
                                :Namespace ""
                                :Null ""
                                :Number ""
                                :Object ""
                                :Operator ""
                                :Package ""
                                :Pair ""
                                :Property ""
                                :Reference ""
                                :Regex ""
                                :Repeat ""
                                :Return ""
                                :RuleSet ""
                                :Scope ""
                                :Section ""
                                :Snippet ""
                                :Specifier ""
                                :Statement ""
                                :String ""
                                :Struct ""
                                :SwitchStatement ""
                                :Table ""
                                :Terminal ""
                                :Text ""
                                :Type ""
                                :TypeParameter ""
                                :Unit ""
                                :Value ""
                                :Variable ""
                                :WhileStatement ""}}})

(local bar {:attach_events [:BufWinEnter :BufWritePost]
            :update_events {:win [:CursorMoved :WinResized :InsertLeave]
                            :buf [:BufModifiedSet :FileChangedShellPost]
                            :global [:DirChanged :VimResized]}
            :sources (fn [buf _]
                       (case [(. vim.bo buf :ft) (. vim.bo buf :buftype)]
                         [:markdown _] [sources.path sources.markdown]
                         [_ :terminal] [sources.terminal]
                         _ [sources.path]))})

(local menu (let [select #(case (utils.menu.get_current)
                            menu (let [cursor (vim.api.nvim_win_get_cursor menu.win)
                                       component (: (. menu.entries
                                                       (. cursor 1))
                                                    :first_clickable
                                                    (. cursor 2))]
                                   (-?> component
                                        (menu:click_on nil 1 :l))))
                  fuzzy #(case (utils.menu.get_current)
                           menu (menu:fuzzy_find_open))]
              {:keymaps {:q :<C-w>q
                         :<Esc> :<C-w>q
                         :H :<C-w>q
                         :L select
                         :<CR> select
                         :i fuzzy}}))

(dropbar.setup {: icons : bar : menu})
