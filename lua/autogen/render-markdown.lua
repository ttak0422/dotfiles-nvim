-- [nfnl] Compiled from fnl/render-markdown.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local M = require("render-markdown")
  local heading = {enabled = true, icons = {"\243\176\188\143 ", "\243\176\142\168 ", "\243\176\188\145 ", "\243\176\142\178 ", "\243\176\188\147 ", "\243\176\142\180 "}, position = "overlay", igns = {"\243\176\171\142 "}, width = "full", left_margin = 0, left_pad = 0, right_pad = 0, min_width = 0, above = "\226\150\132", below = "\226\150\128", border = false, border_prefix = false, border_virtual = false, render_modes = false, sign = false}
  local paragraph = {enabled = true, left_margin = 0, min_width = 0, render_modes = false}
  local code = {enabled = true, sign = true, style = "full", position = "left", language_pad = 0, language_name = true, disable_background = {"diff"}, width = "full", left_margin = 0, left_pad = 0, right_pad = 0, min_width = 0, border = "thin", above = "\226\150\132", below = "\226\150\128", highlight = "RenderMarkdownCode", highlight_language = nil, inline_pad = 0, highlight_inline = "RenderMarkdownCodeInline", render_modes = false}
  local dash = {enabled = true, icon = "\226\148\128", width = "full", left_margin = 0, highlight = "RenderMarkdownDash", render_modes = false}
  local bullet
  local function _1_(_level, index, value)
    local function _2_(v)
      return string.format("%d.", v)
    end
    local function _3_(v)
      if (v > 1) then
        return v
      else
        return index
      end
    end
    local function _5_(v)
      return v:sub(1, (#v - 1))
    end
    return _2_(_3_(tonumber(_5_(vim.trim(value)))))
  end
  bullet = {enabled = true, icons = {"\226\151\143", "\226\151\139", "\226\151\134", "\226\151\135"}, ordered_icons = _1_, left_pad = 0, right_pad = 0, highlight = "RenderMarkdownBullet", render_modes = false}
  local checkbox = {enabled = true, position = "inline", unchecked = {icon = "\243\176\132\177", highlight = "RenderMarkdownUnchecked", scope_highlight = nil}, checked = {icon = "\243\176\177\146", highlight = "RenderMarkdownChecked", scope_highlight = nil}, custom = {}, render_modes = false}
  local pipe_table = {enabled = true, preset = "none", style = "full", cell = "padded", padding = 1, min_width = 0, border = {"\226\148\140", "\226\148\172", "\226\148\144", "\226\148\156", "\226\148\188", "\226\148\164", "\226\148\148", "\226\148\180", "\226\148\152", "\226\148\130", "\226\148\128"}, alignment_indicator = "\226\148\129", head = "RenderMarkdownTableHead", row = "RenderMarkdownTableRow", filler = "RenderMarkdownTableFill", render_modes = false}
  local callout = {note = {raw = "[!NOTE]", rendered = "\243\176\139\189 Note", hilight = "RenderMarkdownInfo"}, tip = {raw = "[!TIP]", rendered = "\243\176\140\182 Tip", hilight = "RenderMarkdownSuccess"}, important = {raw = "[!IMPORTANT]", rendered = "\243\176\133\190 Important", hilight = "RenderMarkdownHint"}, warning = {raw = "[!WARNING]", rendered = "\243\176\128\170 Warning", hilight = "RenderMarkdownWarn"}, caution = {raw = "[!CAUTION]", rendered = "\243\176\179\166 Caution", hilight = "RenderMarkdownError"}, abstract = {raw = "[!ABSTRACT]", rendered = "\243\176\168\184 Abstract", hilight = "RenderMarkdownInfo"}, summary = {raw = "[!SUMMARY]", rendered = "\243\176\168\184 Summary", hilight = "RenderMarkdownInfo"}, tldr = {raw = "[!TLDR]", rendered = "\243\176\168\184 Tldr", hilight = "RenderMarkdownInfo"}, info = {raw = "[!INFO]", rendered = "\243\176\139\189 Info", hilight = "RenderMarkdownInfo"}, todo = {raw = "[!TODO]", rendered = "\243\176\151\161 Todo", hilight = "RenderMarkdownInfo"}, hint = {raw = "[!HINT]", rendered = "\243\176\140\182 Hint", hilight = "RenderMarkdownSuccess"}, success = {raw = "[!SUCCESS]", rendered = "\243\176\132\172 Success", hilight = "RenderMarkdownSuccess"}, check = {raw = "[!CHECK]", rendered = "\243\176\132\172 Check", hilight = "RenderMarkdownSuccess"}, done = {raw = "[!DONE]", rendered = "\243\176\132\172 Done", hilight = "RenderMarkdownSuccess"}, question = {raw = "[!QUESTION]", rendered = "\243\176\152\165 Question", hilight = "RenderMarkdownWarn"}, help = {raw = "[!HELP]", rendered = "\243\176\152\165 Help", hilight = "RenderMarkdownWarn"}, faq = {raw = "[!FAQ]", rendered = "\243\176\152\165 Faq", hilight = "RenderMarkdownWarn"}, attention = {raw = "[!ATTENTION]", rendered = "\243\176\128\170 Attention", hilight = "RenderMarkdownWarn"}, failure = {raw = "[!FAILURE]", rendered = "\243\176\133\150 Failure", hilight = "RenderMarkdownError"}, fail = {raw = "[!FAIL]", rendered = "\243\176\133\150 Fail", hilight = "RenderMarkdownError"}, missing = {raw = "[!MISSING]", rendered = "\243\176\133\150 Missing", hilight = "RenderMarkdownError"}, danger = {raw = "[!DANGER]", rendered = "\243\177\144\140 Danger", hilight = "RenderMarkdownError"}, error = {raw = "[!ERROR]", rendered = "\243\177\144\140 Error", hilight = "RenderMarkdownError"}, bug = {raw = "[!BUG]", rendered = "\243\176\168\176 Bug", hilight = "RenderMarkdownError"}, example = {raw = "[!EXAMPLE]", rendered = "\243\176\137\185 Example", hilight = "RenderMarkdownHint"}, quote = {raw = "[!QUOTE]", rendered = "\243\177\134\168 Quote", hilight = "RenderMarkdownQuote"}, cite = {raw = "[!CITE]", rendered = "\243\177\134\168 Cite", hilight = "RenderMarkdownQuote"}}
  local link = {enabled = true, footnote = {superscript = true, prefix = "", suffix = ""}, image = "\243\176\165\182 ", email = "\243\176\128\147 ", hyperlink = "\243\176\140\185 ", highlight = "RenderMarkdownLink", wiki = {icon = "\243\177\151\150 ", highlight = "RenderMarkdownWikiLink"}, custom = {web = {pattern = "^http", icon = "\243\176\150\159 "}, youtube = {pattern = "youtube%.com", icon = "\243\176\151\131 "}, github = {pattern = "github%.com", icon = "\243\176\138\164 "}, neovim = {pattern = "neovim%.io", icon = "\238\154\174 "}, stackoverflow = {pattern = "stackoverflow%.com", icon = "\243\176\147\140 "}, discord = {pattern = "discord%.com", icon = "\243\176\153\175 "}, reddit = {pattern = "reddit%.com", icon = "\243\176\145\141 "}}, render_modes = false}
  local sign = {enabled = true, highlight = "RenderMarkdownSign"}
  local indent = {per_level = 0, enabled = false, skip_heading = false}
  M.setup({heading = heading, paragraph = paragraph, code = code, dash = dash, bullet = bullet, checkbox = checkbox, pipe_table = pipe_table, callout = callout, link = link, sign = sign, indent = indent, quote = {enabled = true, icon = "\226\150\139", highlight = "RenderMarkdownQuote", render_modes = false, repeat_linebreak = false}})
end
return vim.cmd("RenderMarkdown")
