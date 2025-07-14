(local rm (require :render-markdown))

(local heading
       {:sign false :icons ["󰼏 " "󰎨 " "󰼑 " "󰎲 " "󰼓 " "󰎴 "]})

(local completions {:blink {:enabled true}})
(local win_options {:conceallevel {:rendered 3} :concealcursor {:rendered :n}})

(rm.setup {:preset :obsidian
           :render_modes [:n :c :t]
           : win_options
           : heading
           : completions})

(vim.cmd :RenderMarkdown)
