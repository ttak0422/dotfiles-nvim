(let [M (setmetatable {:utils (require :dropbar.utils)
                       :api (require :dropbar.api)
                       :sources (require :dropbar.sources)}
                      {:__index (require :dropbar)})
      general {:update_events {:win [:CursorMoved :InsertLeave :WinResized]
                               :buf [:BufModifiedSet :FileChangedShellPost]
                               :global [:DirChanged :VimResized]}}
      icons (let [kinds {:use_devicons true
                         :symbols {:Array ""
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
                                   :Enum ""
                                   :EnumMember ""
                                   :Event ""
                                   :Field ""
                                   :File ""
                                   :Folder ""
                                   :ForStatement ""
                                   :Function ""
                                   :H1Marker ""
                                   :H2Marker ""
                                   :H3Marker ""
                                   :H4Marker ""
                                   :H5Marker ""
                                   :H6Marker ""
                                   :Identifier ""
                                   :IfStatement ""
                                   :Interface ""
                                   :Keyword ""
                                   :List ""
                                   :Log ""
                                   :Lsp ""
                                   :Macro ""
                                   :MarkdownH1 ""
                                   :MarkdownH2 ""
                                   :MarkdownH3 ""
                                   :MarkdownH4 ""
                                   :MarkdownH5 ""
                                   :MarkdownH6 ""
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
                                   :Scope ""
                                   :Snippet ""
                                   :Specifier ""
                                   :Statement ""
                                   :String ""
                                   :Struct ""
                                   :SwitchStatement ""
                                   :Terminal ""
                                   :Text ""
                                   :Type ""
                                   :TypeParameter ""
                                   :Unit ""
                                   :Value ""
                                   :Variable ""
                                   :WhileStatement ""}}
                  ui {:bar {:separator " ▸ " :extends "…"}
                      :menu {:separator " " :indicator " ▸ "}}]
              {:enable true : kinds : ui})
      bar {:sources (fn [buf _]
                      (print (. vim.bo buf :buftype))
                      (if (= (. vim.bo buf :buftype) :terminal)
                          [M.sources.terminal]
                          [M.sources.path]))}
      sources {:path {:preview false}}
      menu (let [select (fn []
                          (case (M.utils.menu.get_current)
                            menu (let [cursor (vim.api.nvim_win_get_cursor menu.win)
                                       component (: (. menu.entries
                                                       (. cursor 1))
                                                    :first_clickable
                                                    (. cursor 2))]
                                   (-?> component
                                        (menu:click_on nil 1 :l)))
                            _ nil))
                 fuzzy (fn []
                         (case (M.utils.menu.get_current)
                           menu (menu:fuzzy_find_open)
                           _ nil))]
             {:keymaps {:q :<C-w>q
                        :<Esc> :<C-w>q
                        :<CR> select
                        :H :<C-w>q
                        :L select
                        :i fuzzy}
              :scrollbar {:enable true}})]
  (M.setup {: general : icons : bar : sources : menu}))
