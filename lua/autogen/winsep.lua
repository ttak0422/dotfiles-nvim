-- [nfnl] Compiled from fnl/winsep.fnl by https://github.com/Olical/nfnl, do not edit.
local no_exec_files = dofile(args.exclude_ft_path)
local M = require("colorful-winsep")
local symbols = {"\226\148\129", "\226\148\131", "\226\148\143", "\226\148\147", "\226\148\151", "\226\148\155"}
return M.setup({symbols = symbols, no_exec_files = no_exec_files, smooth = false})
