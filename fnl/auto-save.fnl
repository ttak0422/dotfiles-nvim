(let [auto-save (require :auto-save)
      utils (require :auto-save.utils.data)
      targets (utils.set_of [:md :markdown :norg :neorg])]
  (auto-save.setup {:events [:InsertLeave :TextChanged]
                    :condition (fn [buf]
                                 (and (= (vim.fn.getbufvar buf :&modifiable) 1)
                                      (. targets
                                         (vim.fn.getbufvar buf :&filetype))))}))
