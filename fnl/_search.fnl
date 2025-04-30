(local lasterisk (require :lasterisk))
(local hlslens (require :hlslens))

(hlslens.setup)

(vim.keymap.set :n "*" (fn []
                         (lasterisk.search)
                         (hlslens.start)))
