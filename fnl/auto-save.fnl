(let [auto-save (require :auto-save)
      utils (require :auto-save.utils.data)
      events [:InsertLeave :TextChanged]
      condition (fn [buf]
                  (if (and (= (vim.fn.getbufvar buf :&modifiable) 1)
                           (. (utils.set_of [:md :markdown :norg :neorg])
                              (vim.fn.getbufvar buf :&filetype)))
                      true
                      false))]
  (auto-save.setup {: events : condition}))
