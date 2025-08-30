(local nap (require :nap))

(macro cmd [c]
  (let [out (.. :<Cmd> c :<CR>)]
    `,out))

(macro def [desc prev-cmd next-cmd]
  (let [prev_desc (.. "< " desc)
        next_desc (.. "> " desc)]
    `{:next {:opts {:desc ,next_desc} :rhs ,next-cmd}
      :prev {:opts {:desc ,prev_desc} :rhs ,prev-cmd}}))

(local diagnostic_wrn_options {:severity {:min vim.diagnostic.severity.WARN}
                               :float false})

(local diagnostic_err_options {:severity {:min vim.diagnostic.severity.ERROR}
                               :float false})

(fn get_qflist_nr [nr]
  (. (vim.fn.getqflist {: nr}) :nr))

(fn safe_qf_colder []
  (let [idx (get_qflist_nr 0)]
    (if (< 1 idx)
        (vim.cmd "silent colder")
        (vim.notify "reached start of quickfix list"))))

(fn safe_qf_cnewer []
  (let [idx (get_qflist_nr 0)
        last_idx (get_qflist_nr "$")]
    (if (< idx last_idx)
        (vim.cmd "silent cnewer")
        (vim.notify "reached end of quickfix list"))))

(local operators {:b (def :buffer
                       (cmd :bprevious)
                       (cmd :bnext))
                  :B (def "buffer (history)"
                       (cmd :BufSurfBack)
                       (cmd :BufSurfForward))
                  :d (def :warning
                       #(vim.diagnostic.goto_prev diagnostic_wrn_options)
                       #(vim.diagnostic.goto_next diagnostic_wrn_options))
                  :D (def :error
                       #(vim.diagnostic.goto_prev diagnostic_err_options)
                       #(vim.diagnostic.goto_next diagnostic_err_options))
                  :e (def :edit "g," "g;")
                  :j (def :jump :<C-o> :<C-i>)
                  :h (def :harpoon
                       #(-> (require :harpoon)
                            (: :list)
                            (: :next))
                       #(: (: (require :harpoon) :list) :next))
                  :q (def "qf (item)"
                       (cmd :Qprev)
                       (cmd :Qnext))
                  :<C-q> (def "qf (file)"
                           (cmd :cpfile)
                           (cmd :cnfile))
                  :<M-q> (def "qf (list)"
                           safe_qf_colder
                           safe_qf_cnewer)
                  :g (nap.gitsigns)})

(nap.setup {:next_prefix "]"
            :prev_prefix "["
            :next_repeat :<c-n>
            :prev_repeat :<c-p>
            :exclude_default_operators [:f :F :z :s "'" :l :L :<C-l> :<M-l>]
            : operators})
