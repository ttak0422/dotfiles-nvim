(let [M (require :better_escape)
      mappings {:i {:j {:k :<Esc>}} :c {} :t {} :v {} :s {}}]
  (M.setup {:timeout vim.o.timeoutlen :default_mappings false : mappings}))
