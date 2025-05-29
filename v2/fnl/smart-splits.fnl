(local ss (require :smart-splits))

(local ignored_filetypes [:nofile :quickfix :prompt])

(local ignored_buftypes [:NvimTree])

(local ignored_events [:BufEnter :WinEnter])

(ss.setup {: ignored_filetypes : ignored_buftypes : ignored_events})
