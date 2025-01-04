(let [M (require :nvim-autopairs)
      disable_filetype [:TelescopePrompt :spectre_panel :norg]
      Rule (require :nvim-autopairs.rule)]
  (M.setup {:map_cr true :check_ts true : disable_filetype})
  (M.add_rules [(Rule "\"\"\"" "\"\"\"" :java)]))
