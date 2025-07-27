(local f vim.fn)
(local alpha (require :alpha))
(local theme (require :alpha.themes.dashboard))
(local section theme.section)

(set theme.section.header.val
     [" ██████   █████              ███                 "
      "░░██████ ░░███              ░░░                  "
      " ░███░███ ░███  █████ █████ ████  █████████████  "
      " ░███░░███░███ ░░███ ░░███ ░░███ ░░███░░███░░███ "
      " ░███ ░░██████  ░███  ░███  ░███  ░███ ░███ ░███ "
      " ░███  ░░█████  ░░███ ███   ░███  ░███ ░███ ░███ "
      " █████  ░░█████  ░░█████    █████ █████░███ █████"
      "░░░░░    ░░░░░    ░░░░░    ░░░░░ ░░░░░ ░░░ ░░░░░ "])

(set theme.section.buttons.val
     [(theme.button :e " New file" ":ene <BAR> startinsert <CR>")
      (theme.button :o " Edit Journal" ":Obsidian today<CR>")
      (theme.button :l " Edit Local Config" ":ConfigLocalEdit<CR>")])

(set theme.section.footer.val
     (let [v (vim.version)]
       (.. :v v.major "." v.minor "." v.patch)))

(set theme.config
     {:layout [{:type :padding
                :val (f.max [2 (f.floor (* (f.winheight 0) 0.3))])}
               section.header
               {:type :padding :val 2}
               section.buttons
               section.footer]
      :opts {:margin 5 :noautocmd true :redraw_on_resize false}})

(alpha.setup theme.config)

(vim.api.nvim_create_autocmd :BufLeave {:once true :callback #(vim.cmd.Alpha)})
