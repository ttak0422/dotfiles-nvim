(local rm (require :render-markdown))

(local heading
       {:sign false :icons ["󰼏 " "󰎨 " "󰼑 " "󰎲 " "󰼓 " "󰎴 "]})

(local completions {:blink {:enabled false}})
(local win_options {:concealcursor {:rendered :nvic}})

(rm.setup {:preset :obsidian
           :render_modes [:n :c :t]
           : win_options
           : heading
           : completions})

(vim.cmd :RenderMarkdown)
