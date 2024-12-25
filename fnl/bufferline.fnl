(let [M (require :bufferline)
      bg {:attribute :bg :highlight :Normal}
      fg {:attribute :fg :highlight :Normal}
      rev_bg {:attribute :fg :highlight :Normal}
      rev_fg {:attribute :bg :highlight :Normal}
      normal {: bg : fg}
      active {:bg rev_bg :fg rev_fg}
      highlights {:fill normal
                  :background normal
                  :tab normal
                  :tab_selected active
                  :buffer_visible {: bg : fg :bold true}
                  :buffer_selected {:bg rev_bg
                                    :fg rev_fg
                                    :bold true
                                    :italic true}
                  :modified normal
                  :modified_visible normal
                  :modified_selected active
                  :duplicate normal
                  :duplicate_visible {: bg : fg :italic true}
                  :duplicate_selected {:bg rev_bg :fg rev_fg :italic true}
                  :separator normal
                  :separator_visible normal
                  :separator_selected normal}
      options {:indicator {:icon "" :style :none}
               :separator_style ["" ""]
               :modified_icon ""
               :show_buffer_icons false
               :show_buffer_close_icons false
               :show_close_icon false
               :left_trunc_marker ""
               :right_trunc_marker ""}]
  (M.setup {: options : highlights}))
