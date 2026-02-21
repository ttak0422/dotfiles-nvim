(local editor
       ((. (require :waitevent) :editor) {:open (fn [ctx _path]
                                                  (ctx.lcd)
                                                  (set vim.bo.bufhidden :wipe))}))
(set vim.env.EDITOR editor)
(set vim.env.GIT_EDITOR editor)
