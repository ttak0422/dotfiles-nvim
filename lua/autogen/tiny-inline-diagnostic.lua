-- [nfnl] Compiled from fnl/tiny-inline-diagnostic.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("tiny-inline-diagnostic")
local options = {add_messages = true, throttle = 150, softwrap = 30, multilines = {always_show = false, enabled = false}, overflow = {mode = "wrap"}, break_line = {after = 30, enabled = false}, format = nil, virt_texts = {priority = 2048}, severity = {vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN, vim.diagnostic.severity.INFO, vim.diagnostic.severity.HINT}, overwrite_events = nil, enable_on_insert = false, enable_on_select = false, multiple_diag_under_cursor = false, show_all_diags_on_cursorline = false, show_source = false, use_icons_from_diagnostic = false}
return M.setup({preset = "nonerdfont", options = options})
