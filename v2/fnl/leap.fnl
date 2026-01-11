(each [modes [lhs rhs desc] (pairs {[:n :x :o] [:s "<Plug>(leap)" :Leap]
                                    :n [:S
                                        "<Plug>(leap-from-window)"
                                        "Leap from window"]})]
  (vim.keymap.set modes lhs rhs {:noremap true :silent true : desc}))
