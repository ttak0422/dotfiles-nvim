(let [M (require :trouble)
      win {}
      preview {:type :main :scratch true}
      keys {:? :help
            :r :refresh
            :R :toggle_refresh
            :q :close
            :o :jump_close
            :<esc> :cancel
            :<cr> :jump
            :<c-s> :jump_split
            :<c-v> :jump_vsplit
            "}" :next
            "]]" :next
            "{" :prev
            "[[" :prev
            :dd :delete
            :d {:action :delete :mode :v}
            :i :inspect
            :p :preview
            :P :toggle_preview
            :zo :fold_open
            :zO :fold_open_recursive
            :zc :fold_close
            :zC :fold_close_recursive
            :za :fold_toggle
            :zA :fold_toggle_recursive
            :zm :fold_more
            :zM :fold_close_all
            :zr :fold_reduce
            :zR :fold_open_all
            :zx :fold_update
            :zX :fold_update_all
            :zn :fold_disable
            :zN :fold_enable
            :zi :fold_toggle_enable
            :gb {:action (fn [view] (view:filter {:buf 0} {:toggle true}))
                 :desc "Toggle Current Buffer Filter"}
            :s {:action (fn [view]
                          (let [f (view:get_filter :severity)
                                severity (% (+ (if f f.filter.severity 0) 1) 4)]
                            (view:filter {: severity}
                                         {:id :severity
                                          :template "{hl:Title}Filter:{hl} {severity}"
                                          :del (= severity 0)})))
                :desc "Toggle Severity Filter"}}
      modes {:lsp_references {:params {:include_declaration true}}
             :lsp_base {:params {:include_current false}}
             :symbols {:desc "document symbols"
                       :mode :lsp_document_symbols
                       :focus false
                       :win {:position :right}
                       :filter {:not {:ft :lua :kind :Package}
                                :any {:ft [:help :markdown]
                                      :kind [:Class
                                             :Constructor
                                             :Enum
                                             :Field
                                             :Function
                                             :Interface
                                             :Method
                                             :Module
                                             :Namespace
                                             :Package
                                             :Property
                                             :Struct
                                             :Trait]}}}}
      icons {:indent {:top "│ "
                      :middle "├╴"
                      :last "└╴"
                      :fold_open " "
                      :fold_closed " "
                      :ws "  "}
             :folder_closed " "
             :folder_open " "
             :kinds {:Array " "
                     :Boolean "󰨙 "
                     :Class " "
                     :Constant "󰏿 "
                     :Constructor " "
                     :Enum " "
                     :EnumMember " "
                     :Event " "
                     :Field " "
                     :File " "
                     :Function "󰊕 "
                     :Interface " "
                     :Key " "
                     :Method "󰊕 "
                     :Module " "
                     :Namespace "󰦮 "
                     :Null " "
                     :Number "󰎠 "
                     :Object " "
                     :Operator " "
                     :Package " "
                     :Property " "
                     :String " "
                     :Struct "󰆼 "
                     :TypeParameter " "
                     :Variable "󰀫 "}}]
  (M.setup {:debug false
            :auto_close false
            :auto_open false
            :auto_preview false
            :auto_refresh true
            :auto_jump false
            :focus false
            :follow true
            :indent_guides true
            :max_items 200
            :multiline true
            :pinned false
            :warn_no_results false
            :open_no_results true
            : win
            : preview
            : keys
            : modes
            : icons}))
