(let [M (require :guess-indent)
      filetype_exclude [:netrw :tutor]
      buftype_exclude [:help :nofile :terminal :prompt]
      on_tab_options {:expandtab false}
      on_space_options {:expandtab true
                        :tabstop :detected
                        :softtabstop :detected
                        :shiftwidth :detected}]
  (M.setup {:auto_cmd true
            :override_editorconfig false
            : filetype_exclude
            : buftype_exclude
            : on_tab_options
            : on_space_options}))
