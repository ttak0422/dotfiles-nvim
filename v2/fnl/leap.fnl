(local M (require :leap))

(local clever (. (require :leap.user) :with_traversal_keys))
(local clever-f (clever :f :F))
(local clever-t (clever :t :T))

(fn ft [spec]
  (M.leap (vim.tbl_deep_extend :keep spec
                               {:inputlen 1
                                :inclusive true
                                :opts {:labels ""
                                       :safe_labels (if (: (vim.fn.mode 1)
                                                           :match :o)
                                                        ""
                                                        nil)}})))

(each [modes [lhs rhs desc] (pairs {[:n :x :o] [:s "<Plug>(leap)" :Leap]
                                    :n [:S
                                        "<Plug>(leap-from-window)"
                                        "Leap from window"]})]
  (vim.keymap.set modes lhs rhs {:noremap true :silent true : desc}))

(each [key spec (pairs {:f {:opts clever-f}
                        :F {:backward true :opts clever-f}
                        :t {:offset -1 :opts clever-t}
                        :T {:backward true :offset 1 :opts clever-t}})]
  (vim.keymap.set [:n :x :o] key #(ft spec)))

(each [modes [lhs rhs desc] (pairs {[:n :x :o] [:s "<Plug>(leap)" :Leap]
                                    :n [:S
                                        "<Plug>(leap-from-window)"
                                        "Leap from window"]})]
  (vim.keymap.set modes lhs rhs {:noremap true :silent true : desc}))
