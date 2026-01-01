(let [fff (require :fff)
      keymaps {:close [:<Esc> :<C-c>]
               :select :<CR>
               :select_split :<C-s>
               :select_vsplit :<C-v>
               :select_tab :<C-t>
               :move_up [:<Up> :<C-p>]
               :move_down [:<Down> :<C-n>]
               :preview_scroll_up :<C-u>
               :preview_scroll_down :<C-d>
               :toggle_debug :<F2>
               :cycle_previous_query :<Up>
               :toggle_select :<Tab>
               :send_to_quickfix :<C-q>}]
  (fff.setup {: keymaps}))
