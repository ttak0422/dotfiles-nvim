(local lasterisk (require :lasterisk))
(local hlslens (require :hlslens))
(vim.keymap.set :n "*" (fn []
                         (lasterisk.search)
                         (hlslens.start)))
