(let [M (require :reacher)
      m vim.keymap.set
      o {:noremap true :silent true :buffer true}
      pattern [:reacher]
      callback (fn []
                 (m :i :<cr> M.finish o)
                 (m :i :<esc> M.cancel o)
                 (m :i :<C-c> M.cancel o)
                 (m :i :<C-n> M.next o)
                 (m :i :<C-p> M.previous o)
                 (m :i :<Down> M.forward_history o)
                 (m :i :<Up> M.backward_history o))]
  (vim.api.nvim_create_autocmd [:FileType] {: pattern : callback}))
