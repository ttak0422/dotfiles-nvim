(let [rustowl (require :rustowl)
      on_attach (fn [_ buffer]
                  (vim.keymap.set :n :<LocalLeader>to #(rustowl.toggle buffer)
                                  {: buffer :desc "Toggle RustOwl"}))]
  (rustowl.setup {:auto_attach true
                  :auto_enable false
                  :idle_time 500
                  :highlight_style :underline
                  :client {: on_attach}}))
