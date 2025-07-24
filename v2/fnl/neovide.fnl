(each [k v (pairs {:neovide_padding_top 5
                   :neovide_padding_bottom 5
                   :neovide_padding_right 5
                   :neovide_padding_left 5
                   :neovide_confirm_quit false
                   :neovide_floating_shadow false})]
  (tset vim.g k v))

(let [map vim.keymap.set
      scale 1.1
      change_scale (fn [delta]
                     (set vim.g.neovide_scale_factor
                          (* vim.g.neovide_scale_factor delta)))
      toggle_zoom (fn []
                    (set vim.g.neovide_fullscreen
                         (not vim.g.neovide_fullscreen)))
      paste-from-clipboard-insert #(vim.api.nvim_put (vim.fn.getreg "+" 1 true)
                                                     (vim.fn.getregtype "+")
                                                     true true)]
  (set vim.o.guifont "PlemolJP Console NF:h15")
  (map :n :<C-+> #(change_scale scale))
  (map :n :<C--> #(change_scale (/ 1 scale)))
  (map :n :<A-Enter> toggle_zoom)
  (map :i :<D-v> paste-from-clipboard-insert)
  (map :c :<D-v> :<C-r>+)
  ;; to avoid <C-r> mapping conflict in zsh
  (map :t :<D-v> "<C-\\><C-n>\"+pi")
  (vim.api.nvim_create_user_command :ToggleNeovideFullScreen toggle_zoom {}))
