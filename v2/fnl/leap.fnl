;(local leap (require :leap))
(local spooky (require :leap-spooky))

(each [modes [lhs rhs desc] (pairs {[:n :x :o] [:s "<Plug>(leap)" :Leap]
                                    :n [:S
                                        "<Plug>(leap-from-window)"
                                        "Leap from window"]})]
  (vim.keymap.set modes lhs rhs {:noremap true :silent true : desc}))

; r,Rを範囲指定の後に指定できるようになる
(spooky.setup {})
