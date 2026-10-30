(local ufo (require :ufo))

(local provider_selector (fn [bufnr ft buftype]
                           (if (or (= ft :markdown) (= ft :markdown_inline))
                               [:indent]
                               [:treesitter :indent])))

(ufo.setup {: provider_selector})

(let [opts {:noremap true :silent true}
      desc (fn [d] {:noremap true :silent true :desc d})]
  (each [_ k (ipairs [[:zR ufo.openAllFolds (desc " open all folds")]
                      [:zr ufo.openFoldsExceptKinds (desc " open folds")]
                      [:zM ufo.closeAllFolds (desc " close all folds")]
                      [:zm ufo.closeAllFolds (desc " close all folds")]])]
    (vim.keymap.set :n (. k 1) (. k 2) (or (. k 3) opts))))
