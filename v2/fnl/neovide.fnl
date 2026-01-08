(each [k v (pairs {:neovide_confirm_quit false
                   :neovide_cursor_animate_in_insert_mode false
                   :neovide_cursor_animation_length 0.1
                   :neovide_cursor_antialiasing false
                   :neovide_floating_corner_radius 0.25
                   :neovide_floating_shadow false
                   :neovide_hide_mouse_when_typing true
                   :neovide_input_ime false
                   :neovide_macos_simple_fullscreen false
                   :neovide_opacity 0.90
                   :neovide_padding_bottom 5
                   :neovide_padding_left 5
                   :neovide_padding_right 5
                   :neovide_window_blurred true
                   :neovide_padding_top 10})]
  (tset vim.g k v))

(let [map vim.keymap.set
      scale 1.1
      change_scale (fn [delta]
                     (set vim.g.neovide_scale_factor
                          (* vim.g.neovide_scale_factor delta)))
      toggle_zoom #(set vim.g.neovide_fullscreen (not vim.g.neovide_fullscreen))
      toggle_blur #(set vim.g.neovide_window_blurred
                        (not vim.g.neovide_window_blurred))
      paste-from-clipboard-insert #(let [lines (vim.fn.getreg "+" 1 true)]
                                     (if (= (length lines) 1)
                                         (vim.api.nvim_paste (. lines 1) true
                                                             -1)
                                         (vim.api.nvim_put lines
                                                           (vim.fn.getregtype "+")
                                                           true true)))]
  (set vim.o.guifont "PlemolJP Console NF:h15")
  (map :n :<C-+> #(change_scale scale))
  (map :n :<C--> #(change_scale (/ 1 scale)))
  (map :n :<A-Enter> toggle_zoom)
  (map :n :<A-Tab> toggle_blur)
  (map :i :<D-v> paste-from-clipboard-insert)
  (map :c :<D-v> :<C-r>+)
  ;; to avoid <C-r> mapping conflict in zsh
  (map :t :<D-v> "<C-\\><C-n>\"+pi")
  (vim.api.nvim_create_user_command :ToggleNeovideFullScreen toggle_zoom {})
  (vim.api.nvim_create_user_command :ToggleNeovideBlur toggle_blur {}))
