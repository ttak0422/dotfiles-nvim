(let [M (require :nvim-autopairs)
      Rule (require :nvim-autopairs.rule)
      ts_config {:go false}
      disable_filetype [:TelescopePrompt :spectre_panel :norg]]
  (M.setup {:map_cr true :check_ts true : ts_config : disable_filetype})
  (M.add_rules [(Rule "\"\"\"" "\"\"\"" :java)]))
