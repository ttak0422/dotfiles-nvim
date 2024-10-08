(let [tools {:log {:level vim.log.levels.ERROR}
             :hover {:border [["" :FloatBorder]
                              ["" :FloatBorder]
                              ["" :FloatBorder]
                              ["" :FloatBorder]
                              ["" :FloatBorder]
                              ["" :FloatBorder]
                              ["" :FloatBorder]
                              ["" :FloatBorder]]}}
      hls {:on_attach (dofile args.on_attach_path)
           :capabilities (dofile args.capabilities_path)}
      dap {}]
  (set vim.g.haskell_tools {: tools : hls : dap}))
