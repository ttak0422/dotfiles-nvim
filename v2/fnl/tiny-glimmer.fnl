(local glimmer (require :tiny-glimmer))

(local overwrite {:search {:enabled false}
                  :paste {:enabled true}
                  :yank {:enabled true}
                  :undo {:enabled true}
                  :redo {:enabled true}})

(glimmer.setup {:enabled true : overwrite})
