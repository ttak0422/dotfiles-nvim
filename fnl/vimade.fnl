(let [M (require :vimade)
      blocklist {:default {:buf_opts {:buftype [:prompt :terminal]}
                           :win_config {:relative true}}}
      fadelevel 0.5
      recipe {:minimalist {:animate false}}]
  (M.setup {: blocklist : fadelevel : recipe}))
