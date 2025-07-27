(fn gitu []
  (if (not= (-> (vim.system [:git :rev-parse :--abbrev-ref :HEAD])
                (: :wait)
                (. :code)) 0)
      (vim.notify "not a git repository" vim.log.levels.WARN)
      (do
        (if (= (length (vim.api.nvim_list_wins)) 1)
            (let [w (vim.api.nvim_win_get_width 0)
                  h (* (vim.api.nvim_win_get_height 0) 2.1)]
              (if (> h w) (vim.cmd.split) (vim.cmd.vsplit))))
        (vim.cmd.enew)
        (let [bufnr (vim.api.nvim_get_current_buf)
              on_exit (fn []
                        (if (not= (length (vim.api.nvim_list_wins)) 1)
                            (let [buf (vim.fn.bufnr "#")]
                              (if (and (not= buf -1)
                                       (vim.api.nvim_buf_is_valid buf))
                                  (vim.api.nvim_win_set_buf (vim.api.nvim_get_current_win)
                                                            buf)))
                            (if (vim.api.nvim_buf_is_valid bufnr)
                                (vim.api.nvim_buf_delete bufnr {:force true}))))]
          (vim.fn.termopen :gitu {: on_exit})
          (vim.cmd.startinsert)
          (tset (. vim.bo bufnr) :bufhidden :wipe)
          (tset (. vim.bo bufnr) :swapfile false)
          (tset (. vim.bo bufnr) :buflisted false)
          (vim.api.nvim_create_autocmd :BufLeave
                                       {:buffer bufnr
                                        :once true
                                        :callback on_exit})))))

(vim.api.nvim_create_user_command :Gitu gitu {})
