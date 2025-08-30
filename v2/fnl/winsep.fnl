(local winsep (require :colorful-winsep))

(winsep.setup {:smooth false
               :exponential_smoothing false
               :no_exec_files [:undotree :gitsigns-blame]
               :animate {:enabled false}
               :indicator_for_2wins {:position :center
                                     :symbols {:start_left ""
                                               :end_left ""
                                               :start_down ""
                                               :end_down ""
                                               :start_up ""
                                               :end_up ""
                                               :start_right ""
                                               :end_right ""}}})
