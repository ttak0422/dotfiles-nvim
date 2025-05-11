(local nap (require :nap))
(local cmd (fn [c] (.. :<cmd> c :<cr>)))

(nap.setup {:next_prefix "]"
            :prev_prefix "["
            :next_repeat :<c-n>
            :prev_repeat :<c-p>
            :exclude_default_operators [:f :F :z :s "'" :l :L :<C-l> :<M-l>]
            :operators {:b {:prev {:rhs (cmd :bprevious)
                                   :opts {:desc "← buffer"}}
                            :next {:rhs (cmd :bnext)
                                   :opts {:desc "→ buffer"}}}
                        :B {:prev {:rhs (cmd :BufSurfBack)
                                   :opts {:desc "← buffer "}}
                            :next {:rhs (cmd :BufSurfForward)
                                   :opts {:desc "→ buffer "}}}}})
