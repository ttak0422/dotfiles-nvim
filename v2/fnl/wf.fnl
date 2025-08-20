(local wf (require :wf))
(local whichkey (require :wf.builtin.which_key))

(wf.setup {:theme :default})

(vim.keymap.set :n :<Leader> (whichkey {:text_insert_in_advance :<Leader>})
                {:noremap true :silent true})
