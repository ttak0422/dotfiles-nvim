-- [nfnl] v2/fnl/render-markdown.fnl
local rm = require("render-markdown")
local heading = {icons = {"\243\176\188\143 ", "\243\176\142\168 ", "\243\176\188\145 ", "\243\176\142\178 ", "\243\176\188\147 ", "\243\176\142\180 "}, sign = false}
local completions = {blink = {enabled = true}}
rm.setup({heading = heading, completions = completions})
return vim.cmd("RenderMarkdown")
