(local zoom (require :neo-zoom))

(local winopts {:offset {:width 180 :height 0.9} :border :single})
(local exclude_buftypes [])
(local presets [{:filetypes [:dapui_.* :dap-repl]
                 :winopts {:offset {:top 0.02
                                    :left 0.26
                                    :width 0.74
                                    :height 0.6}}}])

(local callbacks [(fn []
                    (each [_ command (ipairs ["hi link NeoZoomFloatBg Normal"
                                              "hi link NeoZoomFloatBorder Normal"
                                              "set winhl=Normal:NeoZoomFloatBg,FloatBorder:NeoZoomFloatBorder"])]
                      (vim.cmd command)))])

(zoom.setup {: winopts : exclude_buftypes : presets : callbacks})
