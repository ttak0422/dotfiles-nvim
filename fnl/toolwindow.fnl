(let [M (require :toolwindow)
      qf_open (fn []
                (let [pos (vim.api.nvim_win_get_cursor 0)
                      view (vim.fn.winsaveview)]
                  (vim.cmd :copen)
                  (vim.cmd "wincmd p")
                  (vim.api.nvim_win_set_cursor 0 pos)
                  (vim.fn.winrestview view)))
      qf_close (fn [] (vim.cmd :cclose))]
  (M.register :qf nil qf_close qf_open))