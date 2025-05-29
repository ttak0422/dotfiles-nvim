(local tabout (require :tabout))

(local tabouts [{:open "'" :close "'"}
                {:open "\"" :close "\""}
                {:open "`" :close "`"}
                {:open "(" :close ")"}
                {:open "[" :close "]"}
                {:open "{" :close "}"}
                {:open "<" :close ">"}])

(tabout.setup {:tabkey :<Tab>
               :backwards_tabkey :<S-Tab>
               :act_as_tab false
               :act_as_shift_tab false
               :default_tab :<C-t>
               :default_shift_tab :<C-d>
               :enable_backwards true
               :completion false
               :ignore_beginning false
               : tabouts})
