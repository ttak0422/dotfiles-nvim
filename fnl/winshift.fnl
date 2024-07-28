(let [M (setmetatable {:lib (require :winshift.lib)}
                      {:__index (require :winshift)})
      moving_win_options {:wrap false
                          :cursorline false
                          :cursorcolumn false
                          :colorcolumn ""}
      keymaps {:disable_defaults true
               :win_move_mode {:h :left
                               :j :down
                               :k :up
                               :l :right
                               :H :far_left
                               :J :far_down
                               :K :far_up
                               :L :far_right}}
      picker_chars :ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890
      filter_rules {:cur_win true
                    :floats true
                    ;; ignore
                    :filetype []
                    :buftype []
                    :bufname []}
      window_picker (fn []
                      (M.lib.pick_window {: picker_chars : filter_rules}))]
  (M.setup {:highlight_moving_win true
            :focused_hl_group :Visual
            : moving_win_options
            : keymaps
            : window_picker}))
