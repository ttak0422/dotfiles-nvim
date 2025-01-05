(let [timerly (require :timerly)
      api (require :timerly.api)
      mapping (fn [buf]
                (vim.keymap.set :n :<CR> api.togglestatus {:buffer buf}))]
  (timerly.setup {:minutes [25 5]
                  :on_start (fn []
                              (vim.notify "Start timer" :info))
                  :on_finish (fn [] (vim.notify "Time's up!"))
                  : mapping
                  :position :bottom-right}))
