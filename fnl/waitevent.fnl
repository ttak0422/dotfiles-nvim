(let [M (require :waitevent)
      editor (M.editor {})]
  (set vim.env.GIT_EDITOR editor))
