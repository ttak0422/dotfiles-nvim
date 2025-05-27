(local history (require :history-ignore))

(local ignore_words [:^buf$
                     :^history$
                     :^h$
                     :^q$
                     :^qa$
                     :^w$
                     :^wq$
                     :^wa$
                     :^wqa$
                     :^q!$
                     :^qa!$
                     :^w!$
                     :^wq!$
                     :^wa!$
                     :^wqa!$])

(history.setup {: ignore_words})
