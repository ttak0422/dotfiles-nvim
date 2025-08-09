(local rm (require :render-markdown))

(local anti_conceal {:enabled true :disabled_modes [:n :c :t]})

(local heading
       {:sign false
        :render_modes true
        :position :inline
        :icons ["󰼏 " "󰎨 " "󰼑 " "󰎲 " "󰼓 " "󰎴 "]})

(local code {:conceal_delimiters false :border :thin})
; TODO: fix multi byte bug
; (local checkbox {:unchecked {:icon ""
;                              :highlight :RenderMarkdownUnchecked
;                              :scope_highlight nil}
;                  :checked {:icon ""
;                            :highlight :RenderMarkdownChecked
;                            :scope_highlight nil}})

(local completions {:blink {:enabled false}})
(local win_options {:concealcursor {:rendered :nc}})

(rm.setup {:preset :obsidian
           :render_modes [:n :c :t]
           : anti_conceal
           : win_options
           : heading
           : code
           ;: checkbox
           : completions})

(vim.cmd :RenderMarkdown)
