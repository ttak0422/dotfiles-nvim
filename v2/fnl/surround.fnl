(set vim.g.nvim_surround_no_insert_mappings true)
(set vim.g.nvim_surround_no_normal_mappings true)
(set vim.g.nvim_surround_no_visual_mappings true)

(local surround (require :nvim-surround))
(surround.setup {})

(fn map [mode lhs rhs desc]
  (vim.keymap.set mode lhs rhs {:noremap true :silent true : desc}))

(each [_ [mode lhs rhs desc] (ipairs [[:i
                                       :<C-g>s
                                       "<Plug>(nvim-surround-insert)"
                                       "Add a surrounding pair around the cursor (insert mode)"]
                                      [:i
                                       :<C-g>S
                                       "<Plug>(nvim-surround-insert-line)"
                                       "Add a surrounding pair around the cursor, on new lines (insert mode)"]
                                      [:n
                                       :ys
                                       "<Plug>(nvim-surround-normal)"
                                       "Add a surrounding pair around a motion (normal mode)"]
                                      [:n
                                       :yss
                                       "<Plug>(nvim-surround-normal-cur)"
                                       "Add a surrounding pair around the current line (normal mode)"]
                                      [:n
                                       :yS
                                       "<Plug>(nvim-surround-normal-line)"
                                       "Add a surrounding pair around a motion, on new lines (normal mode)"]
                                      [:n
                                       :ySS
                                       "<Plug>(nvim-surround-normal-cur-line)"
                                       "Add a surrounding pair around the current line, on new lines (normal mode)"]
                                      [:x
                                       :Y
                                       "<Plug>(nvim-surround-visual)"
                                       "Add a surrounding pair around a visual selection"]
                                      [:x
                                       :gY
                                       "<Plug>(nvim-surround-visual-line)"
                                       "Add a surrounding pair around a visual selection, on new lines"]
                                      [:n
                                       :ds
                                       "<Plug>(nvim-surround-delete)"
                                       "Delete a surrounding pair"]
                                      [:n
                                       :cs
                                       "<Plug>(nvim-surround-change)"
                                       "Change a surrounding pair"]
                                      [:n
                                       :cS
                                       "<Plug>(nvim-surround-change-line)"
                                       "Change a surrounding pair, on new lines"]])]
  (map mode lhs rhs desc))
