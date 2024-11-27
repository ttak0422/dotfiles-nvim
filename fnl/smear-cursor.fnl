(if (not vim.g.neovide)
    ((. (require :smear_cursor) :setup) {; cursor_color → Cursor color
                                        ; normal_bg → Normal background
                                        :smear_between_buffers true
                                        :smear_between_neighbor_lines false
                                        :use_floating_windows true
                                        :legacy_computing_symbols_support false}))
