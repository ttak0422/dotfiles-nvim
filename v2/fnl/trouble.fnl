(local trouble (require :trouble))

(local win {})

(local preview {:type :main :scratch true})

(local throttle {:refresh 20
                 :update 10
                 :render 10
                 :follow 100
                 :preview {:ms 100 :debounce true}})

(local modes {:lsp_references {:params {:include_declaration true}}
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
                                              :Trait]}}}})

(local icons {:indent {:top "│ "
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
                      :Variable "󰀫 "}})

(trouble.setup {:auto_close false
                :auto_open false
                :auto_preview false
                :auto_refresh true
                :auto_jump false
                :focus false
                :restore true
                :follow true
                :indent_guides true
                :max_items 200
                :multiline true
                :pinned false
                :warn_no_results false
                :open_no_results true
                : win
                : preview
                : throttle
                : modes
		: icons})
