(let [tools {:log {:level vim.log.levels.ERROR}
             :hover {:border [["" :FloatBorder]
                              ["" :FloatBorder]
                              ["" :FloatBorder]
                              ["" :FloatBorder]
                              ["" :FloatBorder]
                              ["" :FloatBorder]
                              ["" :FloatBorder]
                              ["" :FloatBorder]]}}
      hls {}
      dap {}]
  (set vim.g.haskell_tools {: tools : hls : dap}))
