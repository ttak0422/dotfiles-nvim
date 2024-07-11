(let [M (require :better_escape)
      mappings {:i {:j {:k :<Esc>}}
                :c {:j {:k :<Esc>}}
                :t {:j {:k :<Esc>}}
                :v {:j {:k :<Esc>}}
                :s {:j {:k :<Esc>}}}]
  (M.setup {:mapping [:jk]
            :timeout vim.o.timeoutlen
            :default_mappings true
            : mappings}))
