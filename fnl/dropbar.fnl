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
                                   :Value "fnl/test"
                                   :Variable ""
                                   :WhileStatement ""}}
                  ui {:bar {:separator " ▸ " :extends "…"}
                      :menu {:separator " " :indicator " ▸ "}}]
              {:enable true : kinds : ui})
      bar {:sources (fn [buf _]
                      (print (. vim.bo buf :buftype))
                      (if (= (. vim.bo buf :buftype) :terminal)
                          [M.sources.terminal]
                          [M.sources.path]))}]
  (M.setup {: general : icons : bar}))
