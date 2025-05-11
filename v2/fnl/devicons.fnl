(let [M (require :nvim-web-devicons)
      override_by_filename {}
      override_by_extension {:norg {:icon "" :name :Neorg}}]
  (M.setup {:color_icons false : override_by_filename : override_by_extension}))
