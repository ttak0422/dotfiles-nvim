(let [M (require :lsp-lens)
      sections {:definition false
                :references true
                :implementation true
                :git_authors false}
      ignore_filetype [:prisma]]
  (M.setup {:enable true
            :include_declaration false
            : sections
            : ignore_filetype}))
