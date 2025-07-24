(local auto_save (require :auto-save))
(local data (require :auto-save.utils.data))

(local targets (data.set_of [:md :markdown :norg :neorg]))

(auto_save.setup {:events [:InsertLeave :TextChanged]
                  :debounce_delay 500
                  :condition (fn [buf]
                               (or (and (= (vim.fn.getbufvar buf :&modifiable)
                                           1)
                                        (. targets
                                           (vim.fn.getbufvar buf :&filetype)))
                                   false))})
