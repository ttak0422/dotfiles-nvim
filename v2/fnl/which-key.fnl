(local wk (require :which-key))

(fn delay [ctx]
  (if ctx.plugin 50 200))

(local icons {:mappins true :rules false})

(wk.setup {:preset :helix : delay : icons})
