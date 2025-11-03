(local atone (require :atone))

(local layout {:direction :left :width 0.25})

(local diff_cur_node {:enabled true :split_percent 0.35})

(local keymaps {:tree {:quit [:<C-c> :q]
                       :next_node :j
                       :pre_node :k
                       :undo_to :<CR>
                       :help ["?" :g?]}
                :auto_diff {:quit [:<C-c> :q] :help ["?" :g?]}
                :help {:quit_help [:<C-c> :q]}})

(local ui {:border :single})

(atone.setup {: layout : diff_cur_node : keymaps : ui})
