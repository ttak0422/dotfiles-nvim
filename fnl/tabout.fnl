(let [M (require :tabout)
      tabouts [{:open "'" :close "'"}
               {:open "\"" :close "\""}
               {:open "`" :close "`"}
               {:open "(" :close ")"}
               {:open "[" :close "]"}
               {:open "{" :close "}"}
               {:open "<" :close ">"}]]
  (M.setup {:tabkey "" ; configured in pum
            :backwards_tabkey ""  ; configured in pum
            :act_as_tab false
            :act_as_shift_tab false
            :default_tab :<C-t>
            :default_shift_tab :<C-d>
            :enable_backwards true
            :completion false
            :ignore_beginning false
            : tabouts}))
