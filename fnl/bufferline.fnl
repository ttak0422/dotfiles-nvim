(let [M (require :bufferline)
      options {:modified_icon "[+]"
               :show_buffer_icons false
               :show_buffer_close_icons false
               :show_close_icon false
               :left_trunc_marker ""
               :right_trunc_marker ""}]
  (M.setup {: options}))
