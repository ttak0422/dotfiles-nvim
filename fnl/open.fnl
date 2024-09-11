(let [M (require :open)
      config {:system_open {:cmd args.cmd :args {}}}]
  (M.setup {: config}))
