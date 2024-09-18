-- [nfnl] Compiled from fnl/codewindow.fnl by https://github.com/Olical/nfnl, do not edit.
local exclude_filetypes = dofile(args.exclude_ft_path)
local M = require("codewindow")
local events = {"TextChanged", "InsertLeave", "DiagnosticChanged", "FileWritePost"}
return M.setup({exclude_filetypes = exclude_filetypes, max_minimap_height = nil, max_lines = nil, minimap_width = 10, use_lsp = true, use_treesitter = true, use_git = true, width_multiplier = 4, z_index = 1, show_cursor = true, window_border = "none", relative = "editor", events = events, active_in_terminals = false, auto_enable = false})
