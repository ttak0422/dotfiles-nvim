-- [nfnl] v2/fnl/render-markdown.fnl
local rm = require("render-markdown")
local anti_conceal = {enabled = true, disabled_modes = {"n", "c", "t"}}
local heading = {render_modes = true, position = "inline", icons = {"\243\176\188\143 ", "\243\176\142\168 ", "\243\176\188\145 ", "\243\176\142\178 ", "\243\176\188\147 ", "\243\176\142\180 "}, sign = false}
local code = {border = "thin", conceal_delimiters = false}
local checkbox = {enabled = false}
local bullet = {enabled = false}
local link = {custom = {web = {pattern = "^http", icon = "\243\176\150\159 "}, discord = {pattern = "discord%.com", icon = "\243\176\153\175 "}, github = {pattern = "github%.com", icon = "\243\176\138\164 "}, gitlab = {pattern = "gitlab%.com", icon = "\243\176\174\160 "}, google = {pattern = "google%.com", icon = "\243\176\138\173 "}, neovim = {pattern = "neovim%.io", icon = "\238\154\174 "}, reddit = {pattern = "reddit%.com", icon = "\243\176\145\141 "}, stackoverflow = {pattern = "stackoverflow%.com", icon = "\243\176\147\140 "}, wikipedia = {pattern = "wikipedia%.org", icon = "\243\176\150\172 "}, youtube = {pattern = "youtube%.com", icon = "\243\176\151\131 "}}, slack = {pattern = "%.slack.com", icon = "\238\162\164 "}, confluence = {pattern = "%/confluence/", icon = "\238\158\153 "}}
local completions = {blink = {enabled = false}}
local win_options = {concealcursor = {rendered = "nc"}}
rm.setup({preset = "obsidian", file_types = {"markdown", "Avante"}, render_modes = {"n", "c", "t"}, anti_conceal = anti_conceal, win_options = win_options, heading = heading, code = code, checkbox = checkbox, bullet = bullet, link = link, completions = completions})
return vim.cmd("RenderMarkdown")
