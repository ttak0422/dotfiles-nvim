(local autopairs (require :nvim-autopairs))
(local rule (require :nvim-autopairs.rule))

(autopairs.setup {:map_cr true
                  :check_ts true
                  :ts_config {:go false}
                  :disable_filetype [:TelescopePrompt :spectre_panel :norg]})

(autopairs.add_rules [(rule "\"\"\"" "\"\"\"" :java)])
