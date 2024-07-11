-- [nfnl] Compiled from fnl/pqf.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("pqf")
local signs = {error = "\239\129\151", warning = "\239\129\177", info = "\239\129\154", hint = "\239\129\153"}
return M.setup({signs = signs, max_filename_length = 0, show_multiple_lines = false})
