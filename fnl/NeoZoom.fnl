((. (require :neo-zoom) :setup) [:popup
                                 [:enabled true]
                                 :exclude_buftypes
                                 [:terminal]
                                 :winopts
                                 {:offset {:width 150 :height 0.85}
                                  :border :none}
                                 :presets
                                 [{:filetypes [:dapui_.* :dap-repl]
                                   :winopts {:offset {:top 0.02
                                                      :left 0.26
                                                      :width 0.74
                                                      :height 0.25}}}
                                  {:filetypes [:markdown]
                                   :callbacks [(fn []
                                                 (set vim.wo.wrap true))]}]])
