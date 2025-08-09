-- [nfnl] v2/fnl/render-markdown.fnl
local rm = require("render-markdown")
local anti_conceal = {enabled = true, disabled_modes = {"n", "c", "t"}}
local heading = {render_modes = true, position = "inline", icons = {"\243\176\188\143 ", "\243\176\142\168 ", "\243\176\188\145 ", "\243\176\142\178 ", "\243\176\188\147 ", "\243\176\142\180 "}, sign = false}
local code = {border = "thin", conceal_delimiters = false}
local completions = {blink = {enabled = false}}
local win_options = {concealcursor = {rendered = "nc"}}
rm.setup({preset = "obsidian", render_modes = {"n", "c", "t"}, anti_conceal = anti_conceal, win_options = win_options, heading = heading, code = code, completions = completions})
return vim.cmd("RenderMarkdown")
