(vim.api.nvim_del_keymap :n :<Leader>)
(vim.cmd "nmap <Leader>ff <CMD>Telescope<CR>")
(vim.schedule (fn []
                (vim.api.nvim_feedkeys (vim.api.nvim_replace_termcodes :<Leader>
                                                                       true
                                                                       false
                                                                       true)
                                       :m true)))
