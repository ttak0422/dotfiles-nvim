(local auto_save (require :auto-save))
(local data (require :auto-save.utils.data))

(local targets (data.set_of [:md :markdown :norg :neorg]))

(auto_save.setup {:events [:InsertLeave :TextChanged]
                  :debounce_delay 500
                  ; ui2 can enter its pager when commands follow a visible save message.
                  :execution_message {:message "" :cleaning_interval 0}
                  :condition (fn [buf]
                               (or (and (= (vim.fn.getbufvar buf :&modifiable)
                                           1)
                                        (. targets
                                           (vim.fn.getbufvar buf :&filetype)))
                                   false))})
