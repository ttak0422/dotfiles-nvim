(local timerly (require :timerly))
(local api (require :timerly.api))

(timerly.setup {:position :top-right
                :mapping (fn [buf]
                           (vim.keymap.set :n :<CR> api.togglestatus
                                           {:buffer buf}))})
