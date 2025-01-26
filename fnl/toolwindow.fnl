(let [W (require :toolwindow)
      Terminal (. (require :toggleterm.terminal) :Terminal)
      term_table {}
      term_open (fn [_plugin args]
                  (doto (let [val (. term_table args.idx)]
                          (if (= val nil)
                              (let [term (Terminal:new {:direction :float})]
                                (tset term_table args.idx term)
                                term)
                              (. term_table args.idx)))
                    (: :open)))
      term_close (fn [plugin]
                   (if (and (not= plugin nil) (not= plugin.is_open nil)
                            (plugin:is_open))
                       (plugin:close)))
      qf_open (fn []
                (let [pos (vim.api.nvim_win_get_cursor 0)
                      view (vim.fn.winsaveview)]
                  (vim.cmd :copen)
                  (vim.cmd "wincmd p")
                  (vim.api.nvim_win_set_cursor 0 pos)
                  (vim.fn.winrestview view)))
      qf_close (fn [] (vim.cmd :cclose))] ; (W.register :term nil term_open term_close)
  (W.register :terminal nil term_close term_open)
  (W.register :qf nil qf_close qf_open))
