-- [nfnl] v2/fnl/guess-indent.fnl
local guess_indent = require("guess-indent")
return guess_indent.setup({auto_cmd = true, filetype_exclude = {"netrw", "tutor"}, buftype_exclude = {"help", "nofile", "terminal", "prompt"}, on_tab_options = {expandtab = false}, on_space_options = {expandtab = true, tabstop = "detected", softtabstop = "detected", shiftwidth = "detected"}, override_editorconfig = false})
