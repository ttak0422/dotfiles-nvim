(let [M (require :nvim-autopairs)
      Rule (require :nvim-autopairs.rule)]
  (M.setup {:map_cr true :check_ts true})
  (M.add_rules [(Rule "\"\"\"" "\"\"\"" :java)]))
