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

(local link {:custom {:web {:pattern :^http :icon "󰖟 "}
                      :discord {:pattern "discord%.com" :icon "󰙯 "}
                      :github {:pattern "github%.com" :icon "󰊤 "}
                      :gitlab {:pattern "gitlab%.com" :icon "󰮠 "}
                      :google {:pattern "google%.com" :icon "󰊭 "}
                      :neovim {:pattern "neovim%.io" :icon " "}
                      :reddit {:pattern "reddit%.com" :icon "󰑍 "}
                      :stackoverflow {:pattern "stackoverflow%.com"
                                      :icon "󰓌 "}
                      :wikipedia {:pattern "wikipedia%.org" :icon "󰖬 "}
                      :youtube {:pattern "youtube%.com" :icon "󰗃 "}}
             :slack {:pattern "%.slack.com" :icon " "}
             :confluence {:pattern "%/confluence/" :icon " "}})

(local completions {:blink {:enabled false}})
(local win_options {:concealcursor {:rendered :nc}})

(rm.setup {:preset :obsidian
           :file_types [:markdown :Avante]
           :render_modes [:n :c :t]
           : anti_conceal
           : win_options
           : heading
           : code
           ;: checkbox
           : link
           : completions})

(vim.cmd :RenderMarkdown)
