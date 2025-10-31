;; WIP
(macro cond [...]
  (let [xs [...]
        n (length xs)]
    (assert (> n 0) "cond!: at least one clause is required")
    (assert (= (% n 2) 0) "cond!: clauses must be pairs: test expr ...")
    (var acc nil)
    (for [i n 2 -2]
      (let [a (. xs (- i 1))
            b (. xs i)]
        (if (= a `_)
            (do
              (assert (= i n) "cond!: _ must be the last clause")
              (set acc b))
            (let [head (and (= (type a) :table) (> (length a) 0) (. a 1))]
              (if (and head (= (tostring head) :let))
                  (do
                    (assert (= (length a) 3)
                            "cond!: :let form is (:let [bindings] test)")
                    (let [bindings (. a 2)
                          test (. a 3)]
                      (set acc `(let ,bindings (if ,test ,b ,acc)))))
                  (set acc `(if ,a ,b ,acc)))))))
    acc))

(local dropbar (require :dropbar))
(local api (require :dropbar.api))
(local utils (require :dropbar.utils))
(local sources (require :dropbar.sources))

(local icons {:ui {:bar {:separator " " :extends "…"}
                   :menu {:separator " " :indicator " "}}
              :kinds {:file_icon (fn [_path] "")
                      :symbols {:Array ""
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
            :update_events {:win [:WinResized]
                            :buf [:BufWinEnter]
                            :global [:DirChanged :VimResized]}
            :sources (fn [buf _]
                       (case [(. vim.bo buf :ft) (. vim.bo buf :buftype)]
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

(local sources {:path {:relative_to (let [find (fn [path]
                                                 (vim.fs.find [:.git]
                                                              {: path
                                                               :upward true}))]
                                      (fn [buf _win]
                                        (let [path (vim.api.nvim_buf_get_name buf)
                                              ft (?. (. vim.bo buf) :ft)]
                                          (or (cond ;;; obsidian ;;;
                                                    (= ft :markdown)
                                                    (let [vault (or (-> (.. (os.getenv :HOME)
                                                                            :/vaults/default/)
                                                                        (vim.fn.fnamemodify ":p:h")
                                                                        (vim.uv.fs_realpath))
                                                                    "")]
                                                      (if (vim.startswith path
                                                                          vault)
                                                          vault))
                                                    ;;; Maven Standard Directory Layout (java / kotlin / scala) ;;;
                                                    (or (= ft :java)
                                                        (= ft :kotlin)
                                                        (= ft :scala))
                                                    (let [root (-> (or (. (find path)
                                                                          1)
                                                                       "")
                                                                   (vim.fn.fnamemodify ":h"))]
                                                      (each [_ p (pairs [:/src/main/java
                                                                         :/src/main/kotlin
                                                                         :/src/main/scala
                                                                         :/src/test/java
                                                                         :/src/test/kotlin
                                                                         :/src/test/scala])]
                                                        (let [l (.. root p)]
                                                          (if (vim.startswith path
                                                                              l)
                                                              ;; FIXME: nfnl's problem?
                                                              (lua "return l"))))))
                                              ;; fallbacks
                                              (cond ;; git project item
                                                    (:let [found (find path)]
                                                          (> (length found) 0))
                                                    (-> (. found 1)
                                                        (vim.fn.fnamemodify ":h"))
                                                    ;; other
                                                    _ "")))))}})

(dropbar.setup {: icons : bar : menu : sources})

(vim.keymap.set :n :gB api.pick {:noremap true :silent true :desc "pick file"})
