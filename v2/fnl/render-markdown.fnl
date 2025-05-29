(local rm (require :render-markdown))

(local heading
       {:sign false :icons ["󰼏 " "󰎨 " "󰼑 " "󰎲 " "󰼓 " "󰎴 "]})

(local completions {:blink {:enabled true}})

(rm.setup {: heading : completions})

(vim.cmd :RenderMarkdown)
