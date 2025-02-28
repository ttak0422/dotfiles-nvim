(local M (require :toggler))

; quickfix
(M.register :qf {:open (fn [] (vim.cmd :copen))
                 :close (fn [] (vim.cmd :cclose))
                 :is_open (fn []
                            (not= (-> (vim.fn.getqflist {:winid 0})
                                      (. :winid))
                                  0))})

; toggleterm
(let [st {}
      open_idx (fn [idx]
                 (-> (case (. st idx)
                       term term
                       _ (let [term (-> (require :toggleterm.terminal)
                                        (. :Terminal)
                                        (: :new {:direction :float}))]
                           (tset st idx term)
                           term))
                     (: :open)))
      is_open_idx (fn [idx]
                    (let [term (. st idx)]
                      (and term (term:is_open))))
      close_idx (fn [idx]
                  (let [term (. st idx)]
                    (if (and term (term:is_open))
                        (term:close))))]
  (for [i 0 9]
    (M.register (.. :term i)
                {:open (fn [] (open_idx i))
                 :close (fn [] (close_idx i))
                 :is_open (fn [] (is_open_idx i))})))
